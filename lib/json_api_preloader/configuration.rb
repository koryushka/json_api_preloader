# frozen_string_literal: true

module JsonApiPreloader
  class Configuration
    DEFAULT_CONFIG_OPTIONS = {
      check_associations: true,
      models_folder: './app/models/**/*.rb'
    }.freeze

    DEFAULT_CONFIG_OPTIONS.each do |option, value|
      define_method(option) do
        options[option].nil? ? value : options[option]
      end

      define_method("#{option}=") do |val|
        options[option] = val
      end
    end

    def initialize
      @options = {}
    end

    private

    attr_reader :options
  end
end
