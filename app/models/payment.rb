class Payment < ActiveRecord::Base
  has_one :authorisation
  has_one :capture
  has_one :void

  def before_create
    self.vendor_tx_code ||= ActiveMerchant::Utils.generate_unique_id
  end
end
