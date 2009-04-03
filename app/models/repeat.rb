class Repeat < ActiveRecord::Base
  include PaymentGateway

  attr_accessor :authorization
  attr_accessor :response
  belongs_to :payment

  def before_create
    payment = create_payment
    self.response = gateway.purchase(
      amount,
      authorization,
      :order_id => payment.vendor_tx_code,
      :description => description
    )

    self.status = response.params['Status']
    self.status_detail = response.params['StatusDetail']
  end
end
