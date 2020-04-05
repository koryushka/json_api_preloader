# frozen_string_literal: true

module JsonApiPreloader
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def preload_from_params_for(model_name)
        class_attribute :preloader_configuration

        self.preloader_configuration = {
          name: model_name.constantize.name
        }
      end
    end

    private

    def preloaded
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

      preloader_configuration[:name]
    end
  end
end
