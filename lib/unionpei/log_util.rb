# coding: utf-8

require 'singleton'
require 'logger'
require 'net/https'
require 'uri'
require_relative 'sdk_config'

module UnionPei
  class LogUtil

    @@logger = nil

    private_class_method :new

    private

    def LogUtil.getLogger
      if !@@logger
        puts "init LogUtil"
        if SDKConfig.instance.logFilePath.nil?
          @@logger = Logger.new(STDOUT)
        else
          @@logger = Logger.new(SDKConfig.instance.logFilePath)
        end
        @@logger.datetime_format = '%Y-%m-%d %H:%M:%S'
        @@logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime} [#{severity}] #{progname}: #{msg}\n"
        end
        @@logger.level = case SDKConfig.instance.logLevel.upcase
                         when 'INFO' then
                           Logger::INFO
                         when 'DEBUG' then
                           Logger::DEBUG
                         when 'WARN' then
                           Logger::WARN
                         when 'ERROR' then
                           Logger::ERROR
                         when 'FATAL' then
                           Logger::FATAL
                         else
                           Logger::UNKNOWN
                       end
      end
      p = LogUtil.parse_caller(caller(0)[2])
      @@logger.progname = p[0].to_s + ":" + p[1].to_s
      @@logger
    end

    def LogUtil.parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = $1
        line = $2.to_i
        method = $3
        [file, line, method]
      end
    end

    public

    def LogUtil.info(msg)
      LogUtil.getLogger.info(msg)
    end

    def LogUtil.debug(msg)
      LogUtil.getLogger.debug(msg)
    end

    def LogUtil.warn(msg)
      LogUtil.getLogger.warn(msg)
    end

    def LogUtil.error(msg)
      LogUtil.getLogger.error(msg)
    end

    def LogUtil.fatal(msg)
      LogUtil.getLogger.fatal(msg)
    end

  end
end
