class Payment < ActiveRecord::Base
  has_one :authorisation
  has_one :capture
  has_one :void
  belongs_to :organisation

  def before_create
    self.vendor_tx_code ||= ActiveMerchant::Utils.generate_unique_id
  end

  def reference
    [vendor_tx_code, vpstxid, tx_auth_no, security_key].join(';')
  end
end
