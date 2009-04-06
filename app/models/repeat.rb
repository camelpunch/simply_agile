class Repeat < ActiveRecord::Base
  include PaymentGateway

  attr_accessor :authorization, :response, :organisation
  belongs_to :payment

  def before_create
    payment = create_payment :organisation => organisation
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
