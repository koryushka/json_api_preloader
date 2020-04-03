# frozen_string_literal: true

module JsonApiPreloader
  class ModelsPreloadChecker
    class << self
      def preload_models?
        @preload_models ||= preload_possible? && preload_required?
      end

      private

      def preload_possible?
        defined?(ActiveRecord)
      end

      def preload_required?
        JsonApiPreloader.configuration.check_associations
      end
    end
  end
end
