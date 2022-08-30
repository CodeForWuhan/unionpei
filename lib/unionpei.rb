# frozen_string_literal: true

require 'unionpei/version'
require 'unionpei/sdk_config'
require 'unionpei/configuration'
require 'unionpei/log_util'
require 'unionpei/cert_util'
require 'unionpei/sdk_util'
require 'unionpei/acp_service'
require 'unionpei/payment'

module UnionPei
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
