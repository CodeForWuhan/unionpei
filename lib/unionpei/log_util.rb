# frozen_string_literal: true

require 'singleton'
require 'logger'
require 'net/https'
require 'uri'
require_relative 'sdk_config'

module UnionPei
  class LogUtil
    @@logger = nil

    private_class_method :new

    def self.getLogger
      unless @@logger
        @@logger = if SDKConfig.instance.logFilePath.nil?
                     Logger.new($stdout)
                   else
                     Logger.new(SDKConfig.instance.logFilePath)
                   end
        @@logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @@logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} [#{severity}] #{progname}: #{msg}\n"
        end
        @@logger.level = case SDKConfig.instance.logLevel.upcase
                         when 'INFO'
                           Logger::INFO
                         when 'DEBUG'
                           Logger::DEBUG
                         when 'WARN'
                           Logger::WARN
                         when 'ERROR'
                           Logger::ERROR
                         when 'FATAL'
                           Logger::FATAL
                         else
                           Logger::UNKNOWN
                         end
      end
      p = LogUtil.parse_caller(caller(0)[2])
      @@logger.progname = "#{p[0]}:#{p[1]}"
      @@logger
    end

    def self.parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = Regexp.last_match(1)
        line = Regexp.last_match(2).to_i
        method = Regexp.last_match(3)
        [file, line, method]
      end
    end

    def self.info(msg)
      LogUtil.getLogger.info(msg)
    end

    def self.debug(msg)
      LogUtil.getLogger.debug(msg)
    end

    def self.warn(msg)
      LogUtil.getLogger.warn(msg)
    end

    def self.error(msg)
      LogUtil.getLogger.error(msg)
    end

    def self.fatal(msg)
      LogUtil.getLogger.fatal(msg)
    end
  end
end
