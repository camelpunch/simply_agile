class Capture < ActiveRecord::Base
  include PaymentGateway
  
  attr_accessor :authorization
  attr_accessor :response

  belongs_to :payment

  def before_create
    self.response = gateway.capture(amount, authorization)
    
    self.status = response.params['Status']
    self.status_detail = response.params['StatusDetail']
  end
end
