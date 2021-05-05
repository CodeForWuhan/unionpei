#encoding: utf-8

require "date"
require_relative 'sdk_config'
require_relative 'acp_service'

module UnionPei
  class Payment
    class << self
      def B2C
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
    end
  end
end

