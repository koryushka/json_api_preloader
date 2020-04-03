# frozen_string_literal: true

module JsonApiPreloader
  class AssociationsBuilder
    delegate :models, to: ModelsPreloader

    def call
      models.map do |model_name|
        {
          associations: model_name.constantize.reflect_on_all_associations.map { |ac| { ac.name => ac.klass.name } },
          name: model_name
        }
      end
    end
  end
end
