# frozen_string_literal: true

require 'json_api_preloader/core'
require 'json_api_preloader/models_preloader'
require 'json_api_preloader/models_preload_checker'
require 'json_api_preloader/associations_checker'
require 'json_api_preloader/associations_builder'
require 'json_api_preloader/configuration'
require 'json_api_preloader/version'

module JsonApiPreloader
  class << self
    def configure(&block)
      block.call(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
