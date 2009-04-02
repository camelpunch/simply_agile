class PaymentPlan < ActiveRecord::Base
  default_scope :order => 'price'
end
