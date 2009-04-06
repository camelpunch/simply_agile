class Invoice < ActiveRecord::Base
  VAT_RATE = 15

  belongs_to :payment

  def to_s
    if new_record?
      'New Invoice'
    else
      "sa-#{id}"
    end
  end
end
