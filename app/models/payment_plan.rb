class PaymentPlan < ActiveRecord::Base
  default_scope :order => 'price'

  def total
    price * (1 + Invoice::VAT_RATE / 100.0)
  end
end
