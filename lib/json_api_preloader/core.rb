# frozen_string_literal: true

require 'active_support/core_ext'
module JsonApiPreloader
  module Core
    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute(:builder_configuration)
    end
    module ClassMethods
      def setup_query_builder(model_name = nil, action: nil)
        self.builder_configuration ||= []

        self.builder_configuration << {
          model_name: model_name ? model_name.constantize.name : based_on_controller_name,
          action: action&.to_sym || :index
        }
      end

      def based_on_controller_name
        name.demodulize.gsub('Controller', '').singularize.constantize.name
      end
    end

    private

    def preloaded_query
      included = params[:include]
      return {} if included.nil? || included.empty?

      nested_resources(
        included: included.split(','),
        parent: parent_model
      )
    end

    def modify_params(hsh, ary, parent)
      association = ary.shift
      return unless association

      if parent
        new_parent = AssociationsChecker.new(parent, association).call
        return unless new_parent
      end

      modify_params(hsh[association], ary, new_parent)
    end

    def nested_resources(included:, parent:)
      default_hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      result = included.each_with_object(default_hash) do |param, hash|
        array = param.split('.').map(&:to_sym)
        modify_params(hash, array, parent)
      end
      result
    end

    def preload_models?
      @preload_models ||= ModelsPreloadChecker.preload_models?
    end

    def parent_model
      return unless preload_models?

      config = builder_configuration.detect { |conf| conf[:action] == action_name.to_sym }
      return unless config

      config[:model_name]
    end
  end
end
