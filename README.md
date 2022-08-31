UnionPei - 非官方银联支付（UnionPay）SDK
-------- 

# Install

```ruby
gem 'unionpei'

```

# 快速开始（rails）

## 指定读取设定的配置文件

```ruby
# config/initializers/unionpei.rb
UnionPei.configure do |config|
  if Rails.env.production?
    config.acp_sdk_config_path = Rails.root.join('safe/unionpay/acp_production_sdk.ini')
  end
end

```

## 生成支付的页面
```ruby
# 参数可参考相关文档,或者源码中payment.rb

class PaymentsController < ApplicationController
  
  # B2C 支付
  def union_b2c_pay
    UnionPei::Payment.b2c({})
    render html: UnionPei::Payment.b2c.html_safe
  end

  # B2B 支付
  def union_b2b_pay
    UnionPei::Payment.b2b({})
    render html: UnionPei::Payment.b2b.html_safe
  end

  # 查询订单详情
  def query_trans
    UnionPei::Payment.query_trans({})
  end
end
```

# 参考文档

- 银联测试参数：https://open.unionpay.com/tjweb/user/mchTest/param
- 测试说明：https://open.unionpay.com/tjweb/support/faq/mchlist?id=516
- 证书说明：https://open.unionpay.com/tjweb/support/faq/mchlist?id=21
- API文档：https://open.unionpay.com/tjweb/acproduct/APIList?apiservId=448&acpAPIId=754&bussType=0
- SDK下载：https://open.unionpay.com/tjweb/support/faq/mchlist?id=38
- 测试卡信息：https://open.unionpay.com/tjweb/support/faq/mchlist?id=4
- B2B：https://open.unionpay.com/tjweb/acproduct/list?apiSvcId=452&index=999

# 免责声明

本Gem对以下非官方代码进行封装和改造：

https://open.unionpay.com/tjweb/support/faq/mchlist?id=38

代码仅供参考学习，生产环境请自行封装代码。

