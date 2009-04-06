class Invoice < ActiveRecord::Base
  VAT_RATE = 15

  belongs_to :payment
end
