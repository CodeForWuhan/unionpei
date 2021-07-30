# coding: utf-8

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

      path = File.dirname(__FILE__)
      ini = IniParse.parse(File.read("#{path}/acp_sdk.ini").force_encoding("UTF-8"))

      @frontTransUrl = ini["acpsdk"]["acpsdk.frontTransUrl"]
      @singleQueryUrl = ini["acpsdk"]["acpsdk.singleQueryUrl"]
      @backTransUrl = ini["acpsdk"]["acpsdk.backTransUrl"]
      @batchTransUrl = ini["acpsdk"]["acpsdk.batchTransUrl"]
      @fileTransUrl = ini["acpsdk"]["acpsdk.fileTransUrl"]
      @appTransUrl = ini["acpsdk"]["acpsdk.appTransUrl"]
      @cardTransUrl = ini["acpsdk"]["acpsdk.cardTransUrl"]

      @jfFrontTransUrl = ini["acpsdk"]["acpsdk.jfFrontTransUrl"]
      @jfSingleQueryUrl = ini["acpsdk"]["acpsdk.jfSingleQueryUrl"]
      @jfBackTransUrl = ini["acpsdk"]["acpsdk.jfBackTransUrl"]
      @jfCardTransUrl = ini["acpsdk"]["acpsdk.jfCardTransUrl"]
      @jfAppTransUrl = ini["acpsdk"]["acpsdk.jfAppTransUrl"]

      @qrcBackTransUrl = ini["acpsdk"]["acpsdk.qrcBackTransUrl"]
      @qrcB2cIssBackTransUrl = ini["acpsdk"]["acpsdk.qrcB2cIssBackTransUrl"]
      @qrcB2cMerBackTransUrl = ini["acpsdk"]["acpsdk.qrcB2cMerBackTransUrl"]

      @signMethod = ini["acpsdk"]["acpsdk.signMethod"]
      @signMethod = @signMethod.to_s if !@signMethod.nil?
      @version = ini["acpsdk"]["acpsdk.version"]
      @version = "5.0.0" if @version.nil?

      @ifValidateCNName = ini["acpsdk"]["acpsdk.ifValidateCNName"]
      @ifValidateCNName = true if @ifValidateCNName.nil?
      @ifValidateRemoteCert = ini["acpsdk"]["acpsdk.ifValidateRemoteCert"]
      @ifValidateRemoteCert = false if @ifValidateRemoteCert.nil?

      @signCertPath = ini["acpsdk"]["acpsdk.signCert.path"]
      @signCertPwd = ini["acpsdk"]["acpsdk.signCert.pwd"]
      @signCertPwd = @signCertPwd.to_s if !@signCertPwd.nil?

      @validateCertDir = ini["acpsdk"]["acpsdk.validateCert.dir"]
      @encryptCertPath = ini["acpsdk"]["acpsdk.encryptCert.path"]
      @rootCertPath = ini["acpsdk"]["acpsdk.rootCert.path"]
      @middleCertPath = ini["acpsdk"]["acpsdk.middleCert.path"]

      @frontUrl = ini["acpsdk"]["acpsdk.frontUrl"]
      @backUrl = ini["acpsdk"]["acpsdk.backUrl"]

      @encoding = ini["acpsdk"]["acpsdk.encoding"]
      @secureKey = ini["acpsdk"]["acpsdk.secureKey"]
      @secureKey = @secureKey.to_s if !@secureKey.nil?

      @logFilePath = ini["acpsdk"]["acpsdk.log.file.path"]
      @logLevel = ini["acpsdk"]["acpsdk.log.level"]

      @encoding = 'UTF-8'

    end
  end
end



