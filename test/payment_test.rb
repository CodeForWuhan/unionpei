# frozen_string_literal: true

require 'test_helper'

class PaymentTest < Minitest::Test
  def setup
    @config = UnionPei::SDKConfig.instance
  end
end
