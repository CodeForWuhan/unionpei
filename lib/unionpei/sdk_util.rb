# coding: utf-8

require 'singleton'
require 'logger'
require 'net/https'
require 'uri'
require 'base64'
require "zlib"
require_relative 'sdk_config'
require_relative 'cert_util'


module UnionPei
  class SDKUtil

    def SDKUtil.post(url, content)
      LogUtil.info("post url:["+url+"]")
      LogUtil.info("post content:["+content+"]")
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"
      if !SDKConfig.instance.ifValidateRemoteCert
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      res = http.post(uri.path, content).body.force_encoding(SDKConfig.instance.encoding)
      LogUtil.info('resp:['+res+']')
      return res
    end

    def SDKUtil.createLinkString(para, sort, encode)
      linkString = ""
      keys = para.keys
      if sort
        keys = keys.sort
      end
      for key in keys
        value = para[key]
        #         print(key + ":" + value)
        if encode
          value = URI.encode_www_form_component(value)
        end
        # print(str(type(key))+":"+str(type(value))+":"+str(key)+":"+str(value))
        linkString = linkString + key + "=" + value + "&"
      end
      linkString = linkString[0, linkString.length - 1]
      #    print (linkString)
      return linkString
    end

    def SDKUtil.filterNoneValue(para)
      keys = para.keys
      for key in keys
        value = para[key]
        if !value or value == ""
          para.delete(key)
        end
      end
    end

    def SDKUtil.buildSignature(req, signCertPath=SDKConfig.instance.signCertPath, signCertPwd=SDKConfig.instance.signCertPwd, secureKey=SDKConfig.instance.secureKey)

      SDKUtil.filterNoneValue(req)
      if !req["signMethod"]
        LogUtil.error("signMethod must not null")
        return nil
      end
      if !req["version"]
        LogUtil.error("version must not null")
        return nil
      end
      if "01" == req["signMethod"]
        req["certId"] = CertUtil.getSignCertId(signCertPath, signCertPwd)
        LogUtil.info("=== start to sign ===")
        prestr = SDKUtil.createLinkString(req, true, false)
        LogUtil.info("sorted: [" + prestr + "]")
        prestr = SDKUtil.sha256(prestr)
        LogUtil.info("sha256: [" + prestr + "]")
        LogUtil.info("sign cert: [" + signCertPath + "], pwd: [" + signCertPwd + "]")
        key = CertUtil.getSignPriKey(signCertPath, signCertPwd)
        signature = Base64.encode64(key.sign('sha256', prestr)).gsub(/\n|\r/, '')
        LogUtil.info("signature: [" + signature + "]")
      elsif "11" == req["signMethod"]
        LogUtil.info("=== start to sign ===")
        prestr = createLinkString(req, true, false)
        LogUtil.info("sorted: [" + prestr + "]")
        if secureKey.nil?
          LogUtil.error("secureKey must not null")
          return nil
        end
        prestr = prestr + "&" + sha256(secureKey)
        LogUtil.debug("before final sha256: [" + prestr + "]")
        signature = SDKUtil.sha256(prestr)
        LogUtil.info("signature: [" + signature + "]")
      elsif "12" == ["signMethod"]
        LogUtil.error("sm3算法暂未实现，请勿使用。")
        return nil
      else
        LogUtil.info("invalid signMethod: [" + req["signMethod"].to_s + "]")
      end
      LogUtil.info("=== end of sign ===")
      req["signature"] = signature
      return signature
    end

    def SDKUtil.paraFilter(para)
      result = {}
      for key in para.keys
        if (key == "signature" or para[key] == "")
          next
        else
          result[key] = para[key]
        end
      end
      return result
    end

    def SDKUtil.sha256(data)
      OpenSSL::Digest::SHA256.digest(data).unpack("H*")[0].downcase
    end

    def SDKUtil.putKeyValueToMap(temp, isKey, key, m, decode)
      if isKey
        m[key.to_s] = ""
      else
        if decode
          temp = URI.decode_www_form_component(temp)
        end
        m[key.to_s] = temp
      end
    end

    def SDKUtil.parseQString(respString, decode=false)
      resp = {}
      temp = ""
      key = ""
      isKey = true
      isOpen = false;
      openName = "\0";

      for curChar in respString.split("") #遍历整个带解析的字符串
        if (isOpen)
          if (curChar == openName)
            isOpen = false
          end
          temp = temp + curChar
        elsif (curChar == "{")
          isOpen = true
          openName = "}"
          temp = temp + curChar
        elsif (curChar == "[")
          isOpen = true
          openName = "]"
          temp = temp + curChar
        elsif (isKey and curChar == "=")
          key = temp
          temp = ""
          isKey = false
        elsif (curChar == "&" and not isOpen) # 如果读取到&分割符
          SDKUtil.putKeyValueToMap(temp, isKey, key, resp, decode)
          temp = ""
          isKey = true
        else
          temp = temp + curChar
        end
      end
      SDKUtil.putKeyValueToMap(temp, isKey, key, resp, decode)
      return resp
    end

    def SDKUtil.verify(resp)
      if !resp["signMethod"]
        LogUtil.error("signMethod must not null")
        return nil
      end
      if !resp["version"]
        LogUtil.error("version must not null")
        return nil
      end
      if !resp["signature"]
        LogUtil.error("signature must not null")
        return nil
      end
      signMethod = resp["signMethod"]
      version = resp["version"]
      result = false
      if "01" == signMethod
        LogUtil.info("=== start to verify signature ===")
        signature = resp.delete("signature")
        LogUtil.info("signature: [" + signature + "]")
        prestr = SDKUtil.createLinkString(resp, true, false)
        LogUtil.info("sorted: [" + prestr + "]")
        prestr = SDKUtil.sha256(prestr)
        LogUtil.info("sha256: [" + prestr + "]")
        key = CertUtil.verifyAndGetVerifyKey(resp["signPubKeyCert"])
        if !key
          LogUtil.info("no cert was found by signPubKeyCert: " + resp["signPubKeyCert"])
          result = false
        else
          signature = Base64.decode64(signature)
          result = key.verify("sha256", signature, prestr)
        end
        LogUtil.info("verify signature " + (result ? "succeed" : "fail"))
        LogUtil.info("=== end of verify signature ===")
        return result
      elsif "11" == signMethod or "12" == signMethod
        return SDKUtil.verifyBySecureKey(resp, SDKConfig.instance.secureKey)
      else
        LogUtil.info("Error signMethod [" + signMethod + "] in validate. ")
        return false
      end
    end

    def SDKUtil.verifyBySecureKey(resp, secureKey)
      if resp["signMethod"].nil?
        LogUtil.error("signMethod must not null")
        return nil
      end
      if resp["signature"].nil?
        LogUtil.error("signature must not null")
        return nil
      end
      signMethod = resp["signMethod"]
      result = false
      LogUtil.info("=== start to verify signature ===")
      if "11" == signMethod
        signature = resp.delete("signature")
        LogUtil.info("signature: [" + signature+ "]")
        prestr = createLinkString(resp, true, false)
        LogUtil.info("sorted: [" + prestr + "]")
        beforeSha256 = prestr + "&" + sha256(secureKey)
        LogUtil.debug("before final sha256: [" + beforeSha256 + "]")
        afterSha256 = sha256(beforeSha256)
        result = (afterSha256 == signature)
        if !result
          LogUtil.debug("after final sha256: [" + afterSha256 + "]")
        end
      elsif "12" == signMethod
        LogUtil.error("sm3算法暂未实现，请勿使用。")
      else
        LogUtil.info("Error signMethod [" + signMethod.to_s + "] in validate. ")
      end
      LogUtil.info("verify signature " + (result ? "succeed" : "fail"))
      LogUtil.info("=== end of verify signature ===")
      return result
    end

    def SDKUtil.createAutoFormHtml(params, reqUrl)
      result = "<html><head>    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=" + SDKConfig.instance.encoding + "\" /></head><body onload=\"javascript:document.pay_form.submit();\">    <form id=\"pay_form\" name=\"pay_form\" action=\"" + reqUrl + "\" method=\"post\">"
      for key in params.keys
        value = params[key]
        result += "    <input type=\"hidden\" name=\"" + key + "\" id=\"" + key +"\" value=\""+ value +"\" />\n"
      end
      result += "<!-- <input type=\"submit\" type=\"hidden\">-->    </form></body></html>"
      LogUtil.info("auto post html:" + result)
      return result
    end

    def SDKUtil.encryptPub(data, certPath=SDKConfig.instance.encryptCertPath)
      rsaKey = CertUtil.getEncryptKey(certPath)
      result = rsaKey.public_encrypt(data)
      result = Base64.encode64(result).gsub(/\n|\r/, '')
      return result
    end

    def SDKUtil.decryptPri(data, certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      pkey = CertUtil.getDecryptPriKey(certPath, certPwd)
      data = Base64.decode64(data)
      result = pkey.private_decrypt(data)
      return result
    end

    def SDKUtil.deCodeFileContent(params, fileDirectory)
      if !params["fileContent"]
        return false
      end
      LogUtil.info("---------处理后台报文返回的文件---------")
      fileContent = params["fileContent"]
      if !fileContent
        LogUtil.info("文件内容为空")
        return false
      end
      fileContent = Zlib::Inflate.inflate(Base64.decode64(fileContent))
      filePath = ''
      if !params["fileName"]
        LogUtil.info("文件名为空")
        filePath = fileDirectory + "/" + params["merId"] + "_" + params["batchNo"] + "_" + params["txnTime"] + ".txt"
      else
        filePath = fileDirectory + "/" + params['fileName']
      end
      output = File.new(filePath, 'w')
      if !output
        LogUtil.error "Unable to open file!"
        return false
      end
      output.syswrite(fileContent)
      LogUtil.info "文件位置 >:" + filePath
      output.close
      return true
    end

    def SDKUtil.enCodeFileContent(path)
      fileContent = IO.binread(path)
      fileContent = Base64.encode64(Zlib::Deflate.deflate(fileContent)).gsub(/\n|\r/, '')
    end

    def SDKUtil.getEncryptCert(params)
      if params['encryptPubKeyCert'].nil? or params['certType'].nil?
        LogUtil.error("encryptPubKeyCert or certType is null")
        return -1
      end
      strCert = params['encryptPubKeyCert']
      certType = params['certType']

      x509Cert = CertUtil.getX509Cert(strCert)
      if "01" == certType
        # 更新敏感信息加密公钥
        if x509Cert.serial.to_s == CertUtil.getEncryptCertId
          return 0
        end
        localCertPath = SDKConfig.instance.encryptCertPath
        newLocalCertPath = SDKUtil.genBackupName(localCertPath)
        # 将本地证书进行备份存储
        File.rename(localCertPath, newLocalCertPath)
        f = File.new(localCertPath, "w")
        if !f
          LogUtil.error 'Unable to open file!'
          return -1
        end
        f.syswrite(strCert)
        f.close
        LogUtil.info('save new encryptPubKeyCert success')
        CertUtil.resetEncryptCertPublicKey
        return 1
      elsif "02" == certType
        return 0
      else
        LogUtil.error("unknown cerType:"+certType)
        return -1
      end
    end

    def SDKUtil.genBackupName(fileName)
      i = fileName.rindex('.')
      leftFileName = fileName[0, i]
      rightFileName = fileName[i + 1, fileName.length - i]
      newFileName = leftFileName + '_backup' + '.' + rightFileName
      return newFileName
    end
  end
end


