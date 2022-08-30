# frozen_string_literal: true

module UnionPei
  class Configuration
    attr_accessor :acp_sdk_config_path

    def initialize
      @acp_sdk_config_path = default_acp_sdk_path
    end

    def default_acp_sdk_path
      "#{File.dirname(__FILE__)}/acp_sdk.ini"
    end
  end
end
