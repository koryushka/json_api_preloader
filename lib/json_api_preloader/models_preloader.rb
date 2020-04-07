# frozen_string_literal: true

module JsonApiPreloader
  class ModelsPreloader
    class << self
      def models
        @models ||= begin
          load_models! if load_required?

          model_names
        end
      end

      private

      def load_required?
        return !Rails.application.config.eager_load if defined?(Rails)

        true
      end

      def load_models!
        Dir[models_folder].sort.each { |f| require f }
      end

      def models_folder
        JsonApiPreloader.configuration.models_folder
      end

      def model_names
        ActiveRecord::Base.descendants.collect(&:name)
      end
    end
  end
end
