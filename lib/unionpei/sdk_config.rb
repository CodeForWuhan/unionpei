# frozen_string_literal: true

require 'iniparse'
require 'singleton'

module UnionPei
  class SDKConfig
    include Singleton
    attr_reader :frontTransUrl, :singleQueryUrl, :backTransUrl, :batchTransUrl, :fileTransUrl, :appTransUrl,
                :cardTransUrl, :jfFrontTransUrl, :jfSingleQueryUrl, :jfBackTransUrl, :jfCardTransUrl,
                :jfAppTransUrl, :qrcBackTransUrl, :qrcB2cIssBackTransUrl, :qrcB2cMerBackTransUrl,
                :signMethod, :version, :ifValidateCNName, :ifValidateRemoteCert, :signCertPath, :signCertPwd,
                :validateCertDir, :encryptCertPath, :rootCertPath, :middleCertPath, :frontUrl, :backUrl,
                :encoding, :secureKey, :logFilePath, :logLevel

    def initialize
      ini = parse_acpsdk
      acpsdk = ini['acpsdk']

      @frontTransUrl = acpsdk['acpsdk.frontTransUrl']
      @singleQueryUrl = acpsdk['acpsdk.singleQueryUrl']
      @backTransUrl = acpsdk['acpsdk.backTransUrl']
      @batchTransUrl = acpsdk['acpsdk.batchTransUrl']
      @fileTransUrl = acpsdk['acpsdk.fileTransUrl']
      @appTransUrl = acpsdk['acpsdk.appTransUrl']
      @cardTransUrl = acpsdk['acpsdk.cardTransUrl']

      @jfFrontTransUrl = acpsdk['acpsdk.jfFrontTransUrl']
      @jfSingleQueryUrl = acpsdk['acpsdk.jfSingleQueryUrl']
      @jfBackTransUrl = acpsdk['acpsdk.jfBackTransUrl']
      @jfCardTransUrl = acpsdk['acpsdk.jfCardTransUrl']
      @jfAppTransUrl = acpsdk['acpsdk.jfAppTransUrl']

      @qrcBackTransUrl = acpsdk['acpsdk.qrcBackTransUrl']
      @qrcB2cIssBackTransUrl = acpsdk['acpsdk.qrcB2cIssBackTransUrl']
      @qrcB2cMerBackTransUrl = acpsdk['acpsdk.qrcB2cMerBackTransUrl']

      @signMethod = acpsdk['acpsdk.signMethod']
      @signMethod = @signMethod.to_s unless @signMethod.nil?
      @version = acpsdk['acpsdk.version']
      @version = '5.0.0' if @version.nil?

      @ifValidateCNName = acpsdk['acpsdk.ifValidateCNName']
      @ifValidateCNName = true if @ifValidateCNName.nil?
      @ifValidateRemoteCert = acpsdk['acpsdk.ifValidateRemoteCert']
      @ifValidateRemoteCert = false if @ifValidateRemoteCert.nil?

      @signCertPath = acpsdk['acpsdk.signCert.path']
      @signCertPwd = acpsdk['acpsdk.signCert.pwd']
      @signCertPwd = @signCertPwd.to_s unless @signCertPwd.nil?

      @validateCertDir = acpsdk['acpsdk.validateCert.dir']
      @encryptCertPath = acpsdk['acpsdk.encryptCert.path']
      @rootCertPath = acpsdk['acpsdk.rootCert.path']
      @middleCertPath = acpsdk['acpsdk.middleCert.path']

      @frontUrl = acpsdk['acpsdk.frontUrl']
      @backUrl = acpsdk['acpsdk.backUrl']

      @encoding = acpsdk['acpsdk.encoding']
      @secureKey = acpsdk['acpsdk.secureKey']
      @secureKey = @secureKey.to_s unless @secureKey.nil?

      @logFilePath = acpsdk['acpsdk.log.file.path']
      @logLevel = acpsdk['acpsdk.log.level']

      @encoding = 'UTF-8'
    end

    def parse_acpsdk
      acp_sdk_config_path = ::UnionPei.configuration.acp_sdk_config_path
      @ini ||= IniParse.parse(File.read(acp_sdk_config_path).force_encoding('UTF-8'))
    end
  end
end
