# frozen_string_literal: true

require 'test_helper'

class SDKConfigTest < Minitest::Test
  def setup; end

  def test_init_config
    assert UnionPei.configuration.acp_sdk_config_path.include?('lib/unionpei/acp_sdk.ini')
  end

  def test_config_value
    @config = UnionPei::SDKConfig.instance
    assert @config.appTransUrl == 'https://gateway.test.95516.com/gateway/api/appTransReq.do'
    assert @config.backTransUrl == 'https://gateway.test.95516.com/gateway/api/backTransReq.do'
    assert @config.backUrl == 'http://222.222.222.222:8080/backRcvResponse'
    assert @config.batchTransUrl == 'https://gateway.test.95516.com/gateway/api/batchTrans.do'
    assert @config.cardTransUrl == 'https://gateway.test.95516.com/gateway/api/cardTransReq.do'
    assert @config.encoding == 'UTF-8'
    assert @config.encryptCertPath == 'safe/unionpay/acp_test_enc.cer'
    assert @config.fileTransUrl == 'https://filedownload.test.95516.com/'
    assert @config.frontTransUrl == 'https://gateway.test.95516.com/gateway/api/frontTransReq.do'
    assert @config.frontUrl == 'localhost:3000/subscriptions'
    assert @config.ifValidateCNName == false
    assert @config.ifValidateRemoteCert == false
    assert @config.jfAppTransUrl == 'https://gateway.test.95516.com/jiaofei/api/appTransReq.do'
    assert @config.jfBackTransUrl == 'https://gateway.test.95516.com/jiaofei/api/backTransReq.do'
    assert @config.jfCardTransUrl == 'https://gateway.test.95516.com/jiaofei/api/cardTransReq.do'
    assert @config.jfFrontTransUrl == 'https://gateway.test.95516.com/jiaofei/api/frontTransReq.do'
    assert @config.jfSingleQueryUrl == 'https://gateway.test.95516.com/jiaofei/api/queryTrans.do'
    assert @config.logFilePath == 'log/upacp_sdk_ruby.log'
    assert @config.logLevel == 'INFO'
    assert @config.middleCertPath == 'safe/unionpay/acp_test_middle.cer'
    assert @config.qrcB2cIssBackTransUrl.nil?
    assert @config.qrcB2cMerBackTransUrl.nil?
    assert @config.qrcBackTransUrl.nil?
    assert @config.rootCertPath == 'safe/unionpay/acp_test_root.cer'
    assert @config.secureKey.nil?
    assert @config.signCertPath == 'safe/unionpay/acp_test_sign.pfx'
    assert @config.signCertPwd == '000000'
    assert @config.signMethod == '01'
    assert @config.singleQueryUrl == 'https://gateway.test.95516.com/gateway/api/queryTrans.do'
    assert @config.validateCertDir.nil?
    assert @config.version == '5.1.0'
  end
end
