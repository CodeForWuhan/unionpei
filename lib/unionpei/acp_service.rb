# frozen_string_literal: true

require 'openssl'
require 'base64'
require_relative 'log_util'
require_relative 'sdk_config'
require_relative 'sdk_util'

module UnionPei
  class AcpService
    def self.sign(req, certPath = SDKConfig.instance.signCertPath, certPwd = SDKConfig.instance.signCertPwd)
      SDKUtil.buildSignature(req, certPath, certPwd)
    end

    def self.signByCertInfo(req, certPath, certPwd)
      SDKUtil.buildSignature(req, certPath, certPwd)
    end

    def self.signBySecureKey(req, secureKey)
      SDKUtil.buildSignature(req, nil, nil, secureKey)
    end

    def self.validate(resp)
      SDKUtil.verify(resp)
    end

    def self.validateBySecureKey(resp, secureKey)
      SDKUtil.verifyBySecureKey(resp, secureKey)
    end

    def self.post(params, url)
      content = SDKUtil.createLinkString(params, false, true)
      respString = SDKUtil.post(url, content)
      SDKUtil.parseQString(respString)
    end

    def self.createAutoFormHtml(params, reqUrl)
      SDKUtil.createAutoFormHtml(params, reqUrl)
    end

    def self.getCustomerInfo(customerInfo)
      return '' if customerInfo.nil? || customerInfo.length.zero?

      Base.encode64("{#{SDKUtil.createLinkString(customerInfo, false, false)}}").gsub(/\n|\r/, '')
    end

    def self.getCustomerInfoWithEncrypt(customerInfo)
      return '' if customerInfo.nil? || customerInfo.length.zero?

      encryptedInfo = {}
      customerInfo.each_key do |key|
        encryptedInfo[key] = customerInfo.delete(key) if (key == 'phoneNo') || (key == 'cvn2') || (key == 'expired')
      end
      if encryptedInfo.length.positive?
        encryptedInfo = SDKUtil.createLinkString(encryptedInfo, false, false)
        encryptedInfo = AcpService.encryptData(encryptedInfo, SDKConfig.instance.encryptCertPath)
        customerInfo['encryptedInfo'] = encryptedInfo
      end
      Base64.encode64("{#{SDKUtil.createLinkString(customerInfo, false, false)}}").gsub(/\n|\r/, '')
    end

    def self.parseCustomerInfo(customerInfostr, certPath = SDKConfig.instance.signCertPath, certPwd = SDKConfig.instance.signCertPwd)
      customerInfostr = Base64.decode64(customerInfostr)
      customerInfostr = customerInfostr[1, customerInfostr.length - 1]
      customerInfo = SDKUtil.parseQString(customerInfostr)
      if customerInfo['encryptedInfo']
        encryptedInfoStr = customerInfo.delete('encryptedInfo')
        encryptedInfoStr = AcpService.decryptData(encryptedInfoStr, certPath, certPwd)
        encryptedInfo = SDKUtil.parseQString(encryptedInfoStr)
        encryptedInfo.each_key do |key|
          customerInfo[key] = encryptedInfo[key]
        end
      end
      customerInfo
    end

    def self.getEncryptCertId
      CertUtil.getEncryptCertId
    end

    def self.encryptData(data, certPath = SDKConfig.instance.encryptCertPath)
      SDKUtil.encryptPub(data, certPath)
    end

    def self.decryptData(data, certPath = SDKConfig.instance.signCertPath, certPwd = SDKConfig.instance.signCertPwd)
      SDKUtil.decryptPri(data, certPath, certPwd)
    end

    def self.deCodeFileContent(params, fileDirectory)
      SDKUtil.deCodeFileContent(params, fileDirectory)
    end

    def self.enCodeFileContent(path)
      SDKUtil.enCodeFileContent(path)
    end

    def self.updateEncryptCert(params)
      SDKUtil.getEncryptCert(params)
    end
  end
end
