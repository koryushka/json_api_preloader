# frozen_string_literal: true

RSpec.describe JsonApiPreloader::Core do
  describe '.preload' do
    let(:object) { Object.new }

    before do
      def object.controller_name
        'some_name'
      end

      object.extend(described_class)
    end

    context 'when models are not preloaded' do
      before { allow(JsonApiPreloader::ModelsPreloadChecker).to receive(:preload_models?).and_return(false) }

      context 'when `include` key is provided' do
        before do
          def object.params
            { include: 'collection_to_include' }
          end
        end

        it 'returns proper object' do
          expect(object.send(:preloaded)).to eq(collection_to_include: {})
        end
      end

      context 'when `include` is nil' do
        before do
          def object.params
            { include: nil }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded)).to eq({})
        end
      end

      context 'when `include` is empty string' do
        before do
          def object.params
            { include: '' }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded)).to eq({})
        end
      end

      context 'when `include` absents' do
        before do
          def object.params
            {}
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded)).to eq({})
        end
      end

      context 'one level of nesting' do
        before do
          def object.params
            { include: 'collection,second_collection,third_collection' }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded)).to eq(collection: {}, second_collection: {}, third_collection: {})
        end
      end

      context 'two levels of nesting' do
        before do
          def object.params
            {
              include: 'first_level,first_level_2.second_level,first_level_2.second_level_2,first_level_3.second_level'
            }
          end
        end

        it 'returns proper object' do
          expect(object.send(:preloaded))
            .to eq(
              first_level_2: { second_level: {}, second_level_2: {} }, first_level_3: { second_level: {} },
              first_level: {}
            )
        end
      end

      context 'three levels of nesting' do
        before do
          def object.params
            {
              include: 'first_level,first_level_2,first_level_3,first_level_4.second_level,'\
                       'first_level_4.second_level_2.third_level'
            }
          end
        end

        it 'returns proper object' do
          expect(object.send(:preloaded))
            .to eq(
              first_level: {}, first_level_4: { second_level: {}, second_level_2: { third_level: {} } },
              first_level_2: {}, first_level_3: {}
            )
        end
      end
    end
  end
end
