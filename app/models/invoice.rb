class Invoice < ActiveRecord::Base
  VAT_RATE = 15

  belongs_to :payment
  belongs_to :user

  def to_s
    if new_record?
      'New Invoice'
    else
      "sa-#{id}"
    end
  end
end
