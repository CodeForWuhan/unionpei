# coding: utf-8

require 'openssl'
require 'base64'
require_relative 'log_util'
require_relative 'sdk_config'
require_relative 'sdk_util'

module UnionPei
  class AcpService
    def AcpService.sign(req, certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      SDKUtil.buildSignature(req, certPath, certPwd)
    end

    def AcpService.signByCertInfo(req, certPath, certPwd)
      SDKUtil.buildSignature(req, certPath, certPwd)
    end

    def AcpService.signBySecureKey(req, secureKey)
      SDKUtil.buildSignature(req, nil, nil, secureKey)
    end

    def AcpService.validate(resp)
      SDKUtil.verify(resp)
    end

    def AcpService.validateBySecureKey(resp, secureKey)
      SDKUtil.verifyBySecureKey(resp, secureKey)
    end

    def AcpService.post(params, url)
      content = SDKUtil.createLinkString(params, false, true)
      respString = SDKUtil.post(url, content)
      resp = SDKUtil.parseQString(respString)
      return resp
    end

    def AcpService.createAutoFormHtml(params, reqUrl)
      return SDKUtil.createAutoFormHtml(params, reqUrl)
    end

    def AcpService.getCustomerInfo(customerInfo)
      if(customerInfo == nil or customerInfo.length == 0)
          return ""
      end
      return Base.encode64("{" + SDKUtil.createLinkString(customerInfo,false,false)+"}").gsub(/\n|\r/, '')
    end

    def AcpService.getCustomerInfoWithEncrypt(customerInfo)
      if(customerInfo == nil or customerInfo.length == 0)
        return ""
      end
      encryptedInfo = {}
      for key in customerInfo.keys
        if (key == 'phoneNo' or key == 'cvn2' or key == 'expired')
          encryptedInfo[key] = customerInfo.delete(key)
        end
      end
      if (encryptedInfo.length > 0)
        encryptedInfo = SDKUtil.createLinkString(encryptedInfo, false, false)
        encryptedInfo = AcpService.encryptData(encryptedInfo, SDKConfig.instance.encryptCertPath)
        customerInfo['encryptedInfo'] = encryptedInfo
      end
      return Base64.encode64("{" + SDKUtil.createLinkString(customerInfo,false,false)+"}").gsub(/\n|\r/, '')
    end

    def AcpService.parseCustomerInfo(customerInfostr, certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      customerInfostr = Base64.decode64(customerInfostr)
      customerInfostr = customerInfostr[1, customerInfostr.length-1]
      customerInfo = SDKUtil.parseQString(customerInfostr)
      if customerInfo['encryptedInfo']
        encryptedInfoStr = customerInfo.delete('encryptedInfo')
        encryptedInfoStr = AcpService.decryptData(encryptedInfoStr, certPath, certPwd)
        encryptedInfo = SDKUtil.parseQString(encryptedInfoStr)
        for key in encryptedInfo.keys
          customerInfo[key] = encryptedInfo[key]
        end
      end
      return customerInfo
    end

    def AcpService.getEncryptCertId
      return CertUtil.getEncryptCertId
    end

    def AcpService.encryptData(data, certPath=SDKConfig.instance.encryptCertPath)
        return SDKUtil.encryptPub(data, certPath)
    end

    def AcpService.decryptData(data, certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
        return SDKUtil.decryptPri(data, certPath, certPwd)
    end

    def AcpService.deCodeFileContent(params, fileDirectory)
        return SDKUtil.deCodeFileContent(params, fileDirectory)
    end

    def AcpService.enCodeFileContent(path)
        return SDKUtil.enCodeFileContent(path)
    end

    def AcpService.updateEncryptCert(params)
        return SDKUtil.getEncryptCert(params)
    end
  end
end
