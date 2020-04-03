# frozen_string_literal: true

module JsonApiPreloader
  class AssociationsBuilder
    class << self
      def associations
        @associations ||= ModelsPreloader.models.map do |model_name|
          {
            associations: associations_for(model_name),
            name: model_name
          }
        end
      end

      private

      def associations_for(model_name)
        model = model_name.safe_constantize
        return [] unless model

        model.reflect_on_all_associations.map { |ac| { ac.name => ac.klass.name } }
      end
    end
  end
end
