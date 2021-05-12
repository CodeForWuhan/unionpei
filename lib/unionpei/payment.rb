#encoding: utf-8

require "date"
require_relative 'sdk_config'
require_relative 'acp_service'
module UnionPei
  class Payment
    class << self
      @@default_b2c_req = {
        "version"=>UnionPei::SDKConfig.instance.version,
        "encoding"=>UnionPei::SDKConfig.instance.encoding,
        "signMethod"=>UnionPei::SDKConfig.instance.signMethod,
        "frontUrl"=>UnionPei::SDKConfig.instance.frontUrl,
        "backUrl"=>UnionPei::SDKConfig.instance.backUrl,
        "txnType"=>"01",
        "txnSubType"=>"01",
        "bizType"=>"000201", # 000201 是b2c / 000202 是 b2b
        "channelType"=>"07",
        "currencyCode"=>"156",
        "txnAmt"=>"881000",
        "merId"=>"777290058189920",
        "orderId"=>DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s,
        "txnTime"=>DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s,
        "accessType"=>"0"
      }

      # 【默认大于配置】哲学
      def b2c(req=@@default_b2c_req)
        req = @@default_b2c_req.merge(req)
        UnionPei::AcpService.sign(req)
        url = UnionPei::SDKConfig.instance.frontTransUrl
        UnionPei::AcpService.createAutoFormHtml(req, url)
      end

      @@default_b2b_req = {
        "version"=>UnionPei::SDKConfig.instance.version,
        "encoding"=>UnionPei::SDKConfig.instance.encoding,
        "signMethod"=>UnionPei::SDKConfig.instance.signMethod,
        "frontUrl"=>UnionPei::SDKConfig.instance.frontUrl,
        "backUrl"=>UnionPei::SDKConfig.instance.backUrl,
        "txnType"=>"01",
        "txnSubType"=>"01",
        "bizType"=>"000202", # 000201 是b2c / 000202 是 b2b,
        "channelType"=>"07",
        "currencyCode"=>"156",
        "txnAmt"=>"881000",
        "merId"=>"777290058189920",
        "orderId"=>DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s,
        "txnTime"=>DateTime.parse(Time.now.to_s).strftime("%Y%m%d%H%M%S").to_s,
        "accessType"=>"0",
        "payTimeout"=>DateTime.parse((Time.now + 15 * 60 * 1000).to_s).strftime("%Y%m%d%H%M%S").to_s,
        "bizScene"=> "110001",
        "payeeAcctNm"=> "xx商户",
        "payeeAcctNo"=> "12345678",
        "payeeBankName"=> "xx行"
      }

      def b2b(req=@@default_b2b_req)
        req = @@default_b2b_req.merge(req)
        UnionPei::AcpService.sign(req)
        url = UnionPei::SDKConfig.instance.frontTransUrl
        UnionPei::AcpService.createAutoFormHtml(req, url)
      end
    end
  end
end

