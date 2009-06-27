class Payment < ActiveRecord::Base
  has_one :authorisation
  has_one :capture
  has_one :void
  has_one :invoice
  belongs_to :organisation

  def before_create
    self.vendor_tx_code ||= ActiveMerchant::Utils.generate_unique_id
  end

  def reference
    [vendor_tx_code, vpstxid, tx_auth_no, security_key].join(';')
  end

  def capture_or_repeat(params)
    if capture.nil?
      Capture.create!(
        params.delete_if{ |k,v| k == :description }.merge(:payment => self)
      )
    else
      Repeat.create(params.merge(
          :organisation => organisation,
          :authorization => reference
        ))
    end
  end
end
