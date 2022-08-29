# frozen_string_literal: true

require 'singleton'
require 'logger'
require 'net/https'
require 'uri'
require 'base64'
require 'zlib'
require_relative 'sdk_config'
require_relative 'cert_util'

module UnionPei
  class SDKUtil
    def self.post(url, content)
      LogUtil.info("post url:[#{url}]")
      LogUtil.info("post content:[#{content}]")
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless SDKConfig.instance.ifValidateRemoteCert
      res = http.post(uri.path, content).body.force_encoding(SDKConfig.instance.encoding)
      LogUtil.info("resp:[#{res}]")
      res
    end

    def self.createLinkString(para, sort, encode)
      linkString = ''
      keys = para.keys
      keys = keys.sort if sort
      keys.each do |key|
        value = para[key]
        #         print(key + ":" + value)
        value = URI.encode_www_form_component(value) if encode
        # print(str(type(key))+":"+str(type(value))+":"+str(key)+":"+str(value))
        linkString = "#{linkString}#{key}=#{value}&"
      end
      linkString[0, linkString.length - 1]
      #    print (linkString)
    end

    def self.filterNoneValue(para)
      keys = para.keys
      keys.each do |key|
        value = para[key]
        para.delete(key) if !value || (value == '')
      end
    end

    def self.buildSignature(req, signCertPath = SDKConfig.instance.signCertPath, signCertPwd = SDKConfig.instance.signCertPwd, secureKey = SDKConfig.instance.secureKey)
      SDKUtil.filterNoneValue(req)
      unless req['signMethod']
        LogUtil.error('signMethod must not null')
        return nil
      end
      unless req['version']
        LogUtil.error('version must not null')
        return nil
      end
      if req['signMethod'] == '01'
        req['certId'] = CertUtil.getSignCertId(signCertPath, signCertPwd)
        LogUtil.info('=== start to sign ===')
        prestr = SDKUtil.createLinkString(req, true, false)
        LogUtil.info("sorted: [#{prestr}]")
        prestr = SDKUtil.sha256(prestr)
        LogUtil.info("sha256: [#{prestr}]")
        LogUtil.info("sign cert: [#{signCertPath}], pwd: [#{signCertPwd}]")
        key = CertUtil.getSignPriKey(signCertPath, signCertPwd)
        signature = Base64.encode64(key.sign('sha256', prestr)).gsub(/\n|\r/, '')
        LogUtil.info("signature: [#{signature}]")
      elsif req['signMethod'] == '11'
        LogUtil.info('=== start to sign ===')
        prestr = createLinkString(req, true, false)
        LogUtil.info("sorted: [#{prestr}]")
        if secureKey.nil?
          LogUtil.error('secureKey must not null')
          return nil
        end
        prestr = "#{prestr}&#{sha256(secureKey)}"
        LogUtil.debug("before final sha256: [#{prestr}]")
        signature = SDKUtil.sha256(prestr)
        LogUtil.info("signature: [#{signature}]")
      elsif '12' == ['signMethod']
        LogUtil.error('sm3算法暂未实现，请勿使用。')
        return nil
      else
        LogUtil.info("invalid signMethod: [#{req['signMethod']}]")
      end
      LogUtil.info('=== end of sign ===')
      req['signature'] = signature
      signature
    end

    def self.paraFilter(para)
      result = {}
      para.each_key do |key|
        if (key == 'signature') || (para[key] == '')
          next
        else
          result[key] = para[key]
        end
      end
      result
    end

    def self.sha256(data)
      OpenSSL::Digest::SHA256.digest(data).unpack1('H*').downcase
    end

    def self.putKeyValueToMap(temp, isKey, key, m, decode)
      if isKey
        m[key.to_s] = ''
      else
        temp = URI.decode_www_form_component(temp) if decode
        m[key.to_s] = temp
      end
    end

    def self.parseQString(respString, decode = false)
      resp = {}
      temp = ''
      key = ''
      isKey = true
      isOpen = false
      openName = "\0"

      respString.split('').each do |curChar| # 遍历整个带解析的字符串
        if isOpen
          isOpen = false if curChar == openName
          temp += curChar
        elsif curChar == '{'
          isOpen = true
          openName = '}'
          temp += curChar
        elsif curChar == '['
          isOpen = true
          openName = ']'
          temp += curChar
        elsif isKey && (curChar == '=')
          key = temp
          temp = ''
          isKey = false
        elsif (curChar == '&') && !isOpen # 如果读取到&分割符
          SDKUtil.putKeyValueToMap(temp, isKey, key, resp, decode)
          temp = ''
          isKey = true
        else
          temp += curChar
        end
      end
      SDKUtil.putKeyValueToMap(temp, isKey, key, resp, decode)
      resp
    end

    def self.verify(resp)
      unless resp['signMethod']
        LogUtil.error('signMethod must not null')
        return nil
      end
      unless resp['version']
        LogUtil.error('version must not null')
        return nil
      end
      unless resp['signature']
        LogUtil.error('signature must not null')
        return nil
      end
      signMethod = resp['signMethod']
      version = resp['version']
      result = false
      case signMethod
      when '01'
        LogUtil.info('=== start to verify signature ===')
        signature = resp.delete('signature')
        LogUtil.info("signature: [#{signature}]")
        prestr = SDKUtil.createLinkString(resp, true, false)
        LogUtil.info("sorted: [#{prestr}]")
        prestr = SDKUtil.sha256(prestr)
        LogUtil.info("sha256: [#{prestr}]")
        key = CertUtil.verifyAndGetVerifyKey(resp['signPubKeyCert'])
        if !key
          LogUtil.info("no cert was found by signPubKeyCert: #{resp['signPubKeyCert']}")
          result = false
        else
          signature = Base64.decode64(signature)
          result = key.verify('sha256', signature, prestr)
        end
        LogUtil.info("verify signature #{result ? 'succeed' : 'fail'}")
        LogUtil.info('=== end of verify signature ===')
        result
      when '11', '12'
        SDKUtil.verifyBySecureKey(resp, SDKConfig.instance.secureKey)
      else
        LogUtil.info("Error signMethod [#{signMethod}] in validate. ")
        false
      end
    end

    def self.verifyBySecureKey(resp, secureKey)
      if resp['signMethod'].nil?
        LogUtil.error('signMethod must not null')
        return nil
      end
      if resp['signature'].nil?
        LogUtil.error('signature must not null')
        return nil
      end
      signMethod = resp['signMethod']
      result = false
      LogUtil.info('=== start to verify signature ===')
      case signMethod
      when '11'
        signature = resp.delete('signature')
        LogUtil.info("signature: [#{signature}]")
        prestr = createLinkString(resp, true, false)
        LogUtil.info("sorted: [#{prestr}]")
        beforeSha256 = "#{prestr}&#{sha256(secureKey)}"
        LogUtil.debug("before final sha256: [#{beforeSha256}]")
        afterSha256 = sha256(beforeSha256)
        result = (afterSha256 == signature)
        LogUtil.debug("after final sha256: [#{afterSha256}]") unless result
      when '12'
        LogUtil.error('sm3算法暂未实现，请勿使用。')
      else
        LogUtil.info("Error signMethod [#{signMethod}] in validate. ")
      end
      LogUtil.info("verify signature #{result ? 'succeed' : 'fail'}")
      LogUtil.info('=== end of verify signature ===')
      result
    end

    def self.createAutoFormHtml(params, reqUrl)
      result = "<html><head>    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=#{SDKConfig.instance.encoding}\" /></head><body onload=\"javascript:document.pay_form.submit();\">    <form id=\"pay_form\" name=\"pay_form\" action=\"#{reqUrl}\" method=\"post\">"
      params.each_key do |key|
        value = params[key]
        result += "    <input type=\"hidden\" name=\"#{key}\" id=\"#{key}\" value=\"#{value}\" />\n"
      end
      result += '<!-- <input type="submit" type="hidden">-->    </form></body></html>'
      LogUtil.info("auto post html:#{result}")
      result
    end

    def self.encryptPub(data, certPath = SDKConfig.instance.encryptCertPath)
      rsaKey = CertUtil.getEncryptKey(certPath)
      result = rsaKey.public_encrypt(data)
      Base64.encode64(result).gsub(/\n|\r/, '')
    end

    def self.decryptPri(data, certPath = SDKConfig.instance.signCertPath, certPwd = SDKConfig.instance.signCertPwd)
      pkey = CertUtil.getDecryptPriKey(certPath, certPwd)
      data = Base64.decode64(data)
      pkey.private_decrypt(data)
    end

    def self.deCodeFileContent(params, fileDirectory)
      return false unless params['fileContent']

      LogUtil.info('---------处理后台报文返回的文件---------')
      fileContent = params['fileContent']
      unless fileContent
        LogUtil.info('文件内容为空')
        return false
      end
      fileContent = Zlib::Inflate.inflate(Base64.decode64(fileContent))
      filePath = ''
      if !params['fileName']
        LogUtil.info('文件名为空')
        filePath = "#{fileDirectory}/#{params['merId']}_#{params['batchNo']}_#{params['txnTime']}.txt"
      else
        filePath = "#{fileDirectory}/#{params['fileName']}"
      end
      output = File.new(filePath, 'w')
      unless output
        LogUtil.error 'Unable to open file!'
        return false
      end
      output.syswrite(fileContent)
      LogUtil.info "文件位置 >:#{filePath}"
      output.close
      true
    end

    def self.enCodeFileContent(path)
      fileContent = IO.binread(path)
      fileContent = Base64.encode64(Zlib::Deflate.deflate(fileContent)).gsub(/\n|\r/, '')
    end

    def self.getEncryptCert(params)
      if params['encryptPubKeyCert'].nil? || params['certType'].nil?
        LogUtil.error('encryptPubKeyCert or certType is null')
        return -1
      end
      strCert = params['encryptPubKeyCert']
      certType = params['certType']

      x509Cert = CertUtil.getX509Cert(strCert)
      case certType
      when '01'
        # 更新敏感信息加密公钥
        return 0 if x509Cert.serial.to_s == CertUtil.getEncryptCertId

        localCertPath = SDKConfig.instance.encryptCertPath
        newLocalCertPath = SDKUtil.genBackupName(localCertPath)
        # 将本地证书进行备份存储
        File.rename(localCertPath, newLocalCertPath)
        f = File.new(localCertPath, 'w')
        unless f
          LogUtil.error 'Unable to open file!'
          return -1
        end
        f.syswrite(strCert)
        f.close
        LogUtil.info('save new encryptPubKeyCert success')
        CertUtil.resetEncryptCertPublicKey
        1
      when '02'
        0
      else
        LogUtil.error("unknown cerType:#{certType}")
        -1
      end
    end

    def self.genBackupName(fileName)
      i = fileName.rindex('.')
      leftFileName = fileName[0, i]
      rightFileName = fileName[i + 1, fileName.length - i]
      "#{leftFileName}_backup.#{rightFileName}"
    end
  end
end
