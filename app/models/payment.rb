class Payment < ActiveRecord::Base
  def before_create
    self.vendor_tx_code ||= "#{Date.today.year}-#{Payment.count + 1}"
  end
end
