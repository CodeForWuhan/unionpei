#encoding: utf-8

require "date"
require_relative 'sdk_config'
require_relative 'acp_service'

module UnionPei
  class Payment
    class << self
      def b2c
        req = {}

        req["version"] = UnionPei::SDKConfig.instance.version
        req["encoding"] = UnionPei::SDKConfig.instance.encoding
        req["signMethod"] = UnionPei::SDKConfig.instance.signMethod

        req["frontUrl"] = UnionPei::SDKConfig.instance.frontUrl
        req["backUrl"] = UnionPei::SDKConfig.instance.backUrl

        req["txnType"] = "01"
        req["txnSubType"] = "01"
        req["bizType"] = "000201" # 000201 是b2c / 000202 是 b2b
        req["channelType"] = "07"
        req["currencyCode"] = "156"
        req["txnAmt"] = "881000"

        req["merId"] = "777290058189920"
        req["orderId"] = DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s
        req["txnTime"] = DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s
        req["accessType"] = "0"

        #签名示例
        UnionPei::AcpService.sign(req)
        url = UnionPei::SDKConfig.instance.frontTransUrl

        #前台自提交表单示例
        resp = UnionPei::AcpService.createAutoFormHtml(req, url)
        resp
      end

      def b2b
        req = {}

        req["version"] = Com::UnionPay::Acp::Sdk::SDKConfig.instance.version
        req["encoding"] = Com::UnionPay::Acp::Sdk::SDKConfig.instance.encoding
        req["signMethod"] = Com::UnionPay::Acp::Sdk::SDKConfig.instance.signMethod

        req["frontUrl"] = Com::UnionPay::Acp::Sdk::SDKConfig.instance.frontUrl
        req["backUrl"] = Com::UnionPay::Acp::Sdk::SDKConfig.instance.backUrl

        req["txnType"] = "01"
        req["txnSubType"] = "01"
        req["bizType"] = "000202" # 000201 是b2c / 000202 是 b2b
        req["channelType"] = "07"
        req["currencyCode"] = "156"
        req["txnAmt"] = "881000"

        req["merId"] = "777290058189920"
        req["orderId"] = DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s
        req["txnTime"] = DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s
        req["accessType"] = "0"


        req["payTimeout"] = DateTime.parse((Time.now + 15 * 60 * 1000).to_s).strftime("%Y%m%d%H%M%S").to_s
        req["bizScene"] =  "110001"
        req["payeeAcctNm"] =  "xx商户"
        req["payeeAcctNo"] =  "12345678"
        req["payeeBankName"] =  "xx行"


        #签名示例
        Com::UnionPay::Acp::Sdk::AcpService.sign(req)
        url = Com::UnionPay::Acp::Sdk::SDKConfig.instance.frontTransUrl

        #前台自提交表单示例
        resp = Com::UnionPay::Acp::Sdk::AcpService.createAutoFormHtml(req, url)
        resp
      end
    end
  end
end

