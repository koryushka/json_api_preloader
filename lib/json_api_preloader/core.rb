# frozen_string_literal: true

module JsonApiPreloader
  module Core
    extend ActiveSupport::Concern

    class_methods do
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
      return {} unless included.presence

      nested_resources(
        included: included.split(','),
        parent: preloader_configuration[:name]
      )
    end

    def modify_params(hsh, ary, parent)
      association = ary.shift
      return unless association

      new_parent = AssociationsChecker.new(parent, association).call
      return unless new_parent

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
  end
end
