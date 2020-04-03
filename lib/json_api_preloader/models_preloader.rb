# frozen_string_literal: true

module JsonApiPreloader
  class ModelsPreloader
    class << self
      def models
        @models ||= begin
          load_models! unless eager_loaded?

          model_names
        end
      end

      private

      def eager_loaded?
        Rails.application.config.eager_load
      end

      def load_models!
        Dir[Rails.root.join('app/models/**/*.rb')].sort.each { |f| require f }
      end

      def model_names
        ApplicationRecord.descendants.collect(&:name)
      end
    end
  end
end
