class Void < ActiveRecord::Base
  include PaymentGateway

  attr_accessor :authorization
  attr_accessor :response

  def before_create
    self.response = gateway.void(authorization)

    self.status = response.params['Status']
    self.status_detail = response.params['StatusDetail']
  end
end
