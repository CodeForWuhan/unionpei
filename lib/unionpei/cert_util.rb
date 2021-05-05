# coding: utf-8

require 'openssl'
require 'base64'
require_relative 'log_util'
require_relative 'sdk_config'


module UnionPei
  UNIONPAY_CNNAME = "中国银联股份有限公司"

  class Cert
    attr_accessor :cert, :certId, :key
    @certId
    @key
    @cert
  end

  class CertUtil

    @@signCerts = {}
    @@encryptCert = {}
    @@verifyCerts = {} #5.0.0验签证书，key是certId
    @@verifyCerts5_1_0 = {} #5.1.0验签证书，key是base64的证书内容
    @@middleCert = nil
    @@rootCert = nil

    private
    def CertUtil.initSignCert(certPath, certPwd)
      if !certPath || !certPwd
        LogUtil.info("signCertPath or signCertPwd is none, exit initSignCert")
        return
      end
      LogUtil.info("读取签名证书……")
      cert = Cert.new
      file = IO.binread(certPath)
      p12 = OpenSSL::PKCS12.new(file, certPwd)
      cert.certId = p12.certificate.serial.to_s
      cert.cert = p12.certificate
      cert.key = p12.key
      @@signCerts[certPath] = cert
      LogUtil.info("签名证书读取成功，序列号：" + cert.certId)
    end

    def CertUtil.initEncryptCert(certPath=SDKConfig.instance.encryptCertPath)
        if !certPath
          LogUtil.info("encryptCertPath is none, exit initEncryptCert")
          return
        end
        LogUtil.info("读取加密证书……")
        cert = Cert.new
        file = IO.binread(certPath)
        x509Cert = OpenSSL::X509::Certificate.new(file)
        cert.cert = x509Cert
        cert.certId = x509Cert.serial.to_s
        cert.key = x509Cert.public_key
        @@encryptCert[certPath] = cert
        LogUtil.info("加密证书读取成功，序列号：" + cert.certId)
    end

    def CertUtil.initRootCert()
      if @@rootCert
        return
      end
      if !SDKConfig.instance.rootCertPath
        LogUtil.info("rootCertPath is none, exit initRootCert")
        return
      end
      LogUtil.info("start initRootCert")
      file = IO.binread(SDKConfig.instance.rootCertPath)
      x509Cert = OpenSSL::X509::Certificate.new(file)
      @@rootCert = x509Cert
      LogUtil.info("initRootCert succeed")
    end

    def CertUtil.initMiddleCert()
      if @@middleCert
        return
      end
      if !SDKConfig.instance.middleCertPath
        LogUtil.info("middleCertPath is none, exit initMiddleCert")
        return
      end
      LogUtil.info("start initMiddleCert")
      file = IO.binread(SDKConfig.instance.middleCertPath)
      x509Cert = OpenSSL::X509::Certificate.new(file)
      @@middleCert = x509Cert
      LogUtil.info("initMiddleCert succeed")
    end

    public
    def CertUtil.getSignPriKey(certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      if !@@signCerts[certPath]
        CertUtil.initSignCert(certPath, certPwd)
      end
      @@signCerts[certPath].key
    end

    def CertUtil.getSignCertId(certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      if !@@signCerts[certPath]
        CertUtil.initSignCert(certPath, certPwd)
      end
      @@signCerts[certPath].certId
    end

    def CertUtil.getEncryptKey(certPath=SDKConfig.instance.encryptCertPath)
      if !@@encryptCert[certPath]
        CertUtil.initEncryptCert(certPath)
      end
      @@encryptCert[certPath].key
    end

    def CertUtil.getEncryptCertId(certPath=SDKConfig.instance.encryptCertPath)
      if !@@encryptCert[certPath]
        CertUtil.initEncryptCert(certPath)
      end
      @@encryptCert[certPath].certId
    end

    def CertUtil.verifyAndGetVerifyKey(certBase64String)

      if @@verifyCerts5_1_0[certBase64String]
        return @@verifyCerts5_1_0[certBase64String].key
      end
      initMiddleCert
      initRootCert

      x509Cert = OpenSSL::X509::Certificate.new(certBase64String)

      cert = Cert.new
      cert.cert = x509Cert
      cert.certId = x509Cert.serial.to_s
      cert.key = x509Cert.public_key

      store = OpenSSL::X509::Store.new
      store.purpose = OpenSSL::X509::PURPOSE_ANY
      store.add_cert(x509Cert)
      store.add_cert(@@middleCert)
      store.add_cert(@@rootCert)
      if !store.verify(x509Cert)
        LogUtil.error("validate signPubKeyCert by cert chain failed, error=" + store.error + ", error string=" + store.error_string)
        return nil
      end

      sSubject = x509Cert.subject.to_s
      ss = sSubject.split("@")
      if ss.length <= 2
        LogUtil.error("error sSubject: " + sSubject)
        return nil
      end
      cn = ss[2];
      if SDKConfig.instance.ifValidateCNName
        if UNIONPAY_CNNAME != cn
          LogUtil.error("cer owner is not CUP:" + cn)
          return nil
        elsif UNIONPAY_CNNAME != cn and cn != "00040000:SIGN" #测试环境目前是00040000:SIGN
          LogUtil.error("cer owner is not CUP:" + cn)
          return nil
        end
      end

      LogUtil.info("validate signPubKeyCert by cert succeed: " + certBase64String)
      @@verifyCerts5_1_0[certBase64String] = cert;
      return @@verifyCerts5_1_0[certBase64String].key

      # 用bc的jar用中级证书验证可以单独验时间，然后再用中级证书验一下，但为了和谐统一，目前改store验证书链验证了。
      # if Time.new<x509Cert.not_before or Time.new>x509Cert.not_after
      #   LogUtil..info("verifyPubKeyCert has expired")
      #   return nil
      # end
      # if x509Cert.verify(@@middleKey)
      #   return x509Cert.public_key
      # else
      #   LogUtil.info("validate signPubKeyCert by rootCert failed")
      #   return nil
      # end
    end

    def CertUtil.getDecryptPriKey(certPath=SDKConfig.instance.signCertPath, certPwd=SDKConfig.instance.signCertPwd)
      if !@@signCerts[certPath]
        CertUtil.initSignCert(certPath, certPwd)
      end
      @@signCerts[certPath].key
    end

    def CertUtil.resetEncryptCertPublicKey()
      @@encryptCert = {}
      CertUtil.initEncryptCert
    end

    def CertUtil.getX509Cert(strCert)
      OpenSSL::X509::Certificate.new(strCert)
    end
  end
end
