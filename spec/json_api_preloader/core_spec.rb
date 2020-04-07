# frozen_string_literal: true

require 'byebug'
RSpec.describe JsonApiPreloader::Core do
  describe '.preloaded_query' do
    let(:object) { Object.new }
    before do
      Object.include(described_class)
      # object.extend(described_class)

      allow(JsonApiPreloader::ModelsPreloadChecker).to receive(:preload_models?).and_return(preload_models)
    end

    context 'when models are preloaded' do
      let(:preload_models) { true }
      let(:parent) { 'ParentModel' }
      let(:second_level_double_parent) { nil }
      let(:first_level_double) do
        instance_double(JsonApiPreloader::AssociationsChecker, call: first_level_double_parent)
      end
      let(:second_level_double) do
        instance_double(JsonApiPreloader::AssociationsChecker, call: second_level_double_parent)
      end

      let(:first_level_double_2) do
        instance_double(JsonApiPreloader::AssociationsChecker, call: first_level_double_parent_2)
      end

      before do
        allow(object).to receive(:parent_model).and_return(parent)
        allow(JsonApiPreloader::ModelsPreloadChecker).to receive(:preload_models?).and_return(true)
        allow(JsonApiPreloader::AssociationsChecker)
          .to receive(:new).with(parent, first_level_association).and_return(first_level_double)
        allow(JsonApiPreloader::AssociationsChecker)
          .to receive(:new).with(parent, first_level_association_2).and_return(first_level_double_2)
      end

      context 'one level of nesting' do
        let(:first_level_association) { :first_association }
        let(:first_level_association_2) { :second_association }
        before do
          def object.params
            { include: 'first_association,second_association' }
          end
        end
        context 'when associations exist' do
          let(:first_level_double_parent) { 'SomeModel' }
          let(:first_level_double_parent_2) { 'SomeModel' }

          it 'returns proper object' do
            expect(object.send(:preloaded_query)).to eq(first_association: {}, second_association: {})
          end
        end

        context 'when one association does not exist on the parent model' do
          let(:first_level_double_parent) { nil }
          let(:first_level_double_parent_2) { 'SomeModel' }
          it 'returns proper object' do
            expect(object.send(:preloaded_query)).to eq(second_association: {})
          end
        end
      end

      context 'two levels of nesting' do
        let(:first_level_association) { :first_level }
        let(:first_level_association_2) { :first_level_2 }
        let(:second_level_association) { :second_level }

        before do
          def object.params
            {
              include: 'first_level.second_level,first_level_2'
            }
          end
          allow(JsonApiPreloader::AssociationsChecker)
            .to receive(:new).with(first_level_double_parent, first_level_association).and_return(second_level_double)
          allow(JsonApiPreloader::AssociationsChecker)
            .to receive(:new).with(first_level_double_parent, second_level_association).and_return(second_level_double)
        end

        context 'when associations exist' do
          let(:first_level_double_parent) { 'FirstParentModel' }
          let(:second_level_double_parent) { 'SecondParentModel' }
          let(:first_level_double_parent_2) { 'SomeParent' }

          it 'returns proper object' do
            expect(object.send(:preloaded_query)).to eq(first_level: { second_level: {} }, first_level_2: {})
          end
        end

        context 'when does not associations exist' do
          let(:first_level_double_parent) { 'FirstParentModel' }
          let(:second_level_double_parent) { nil }
          let(:first_level_double_parent_2) { 'SomeParent' }

          it 'returns proper object' do
            expect(object.send(:preloaded_query)).to eq(first_level: {}, first_level_2: {})
          end
        end
      end
    end

    context 'when models are not preloaded' do
      let(:preload_models) { false }

      context 'when `include` key is provided' do
        before do
          def object.params
            { include: 'collection_to_include' }
          end
        end

        it 'returns proper object' do
          expect(object.send(:preloaded_query)).to eq(collection_to_include: {})
        end
      end

      context 'when `include` is nil' do
        before do
          def object.params
            { include: nil }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded_query)).to eq({})
        end
      end

      context 'when `include` is empty string' do
        before do
          def object.params
            { include: '' }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded_query)).to eq({})
        end
      end

      context 'when `include` absents' do
        before do
          def object.params
            {}
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded_query)).to eq({})
        end
      end

      context 'one level of nesting' do
        before do
          def object.params
            { include: 'collection,second_collection,third_collection' }
          end
        end
        it 'returns proper object' do
          expect(object.send(:preloaded_query)).to eq(collection: {}, second_collection: {}, third_collection: {})
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
          expect(object.send(:preloaded_query))
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
          expect(object.send(:preloaded_query))
            .to eq(
              first_level: {}, first_level_4: { second_level: {}, second_level_2: { third_level: {} } },
              first_level_2: {}, first_level_3: {}
            )
        end
      end
    end
  end

  describe '#setup_query_builder' do
    before { Object.include(described_class) }

    context 'single setup per class' do
      subject { Object.setup_query_builder(model_name, action: action) }

      context 'when model name and action are nil' do
        let(:model_name) { nil }
        let(:action) { nil }

        it { is_expected.to eq([{ model_name: 'Object', action: :index }]) }
      end

      context 'when model is set' do
        before do
          class TestModel; end
        end
        let(:model_name) { 'TestModel' }
        let(:action) { nil }

        it { is_expected.to eq([{ model_name: 'TestModel', action: :index }]) }
      end

      context 'when action is set' do
        let(:model_name) { nil }
        let(:action) { :custom_action }

        it { is_expected.to eq([{ model_name: 'Object', action: :custom_action }]) }
      end

      context 'when model and action are set' do
        before do
          class TestModel; end
        end
        let(:model_name) { 'TestModel' }
        let(:action) { :custom_action }

        it { is_expected.to eq([{ model_name: 'TestModel', action: :custom_action }]) }
      end

      context 'when model does not exist' do
        let(:model_name) { 'UnexistentModel' }
        let(:action) { :custom_action }

        it 'raises error' do
          expect { subject }.to raise_error(NameError, "uninitialized constant #{model_name}")
        end
      end
    end

    context 'multiple setups per class' do
      subject do
        Object.setup_query_builder(model_name, action: action)
        Object.setup_query_builder(model_name_2, action: action_2)
      end

      context 'when model name and action are set' do
        before do
          class TestModel end
          class TestModel2 end
        end

        let(:model_name) { 'TestModel' }
        let(:action) { :custom_action }
        let(:model_name_2) { 'TestModel2' }
        let(:action_2) { :custom_action_2 }

        expected_setup = [
          { model_name: 'TestModel', action: :custom_action },
          { model_name: 'TestModel2', action: :custom_action_2 }
        ]
        it { is_expected.to match_array(expected_setup) }
      end
    end
  end
end
