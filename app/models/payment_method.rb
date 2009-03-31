class PaymentMethod < ActiveRecord::Base
  attr_accessor :cardholder_name
  attr_accessor :card_number
  attr_accessor :cv2

  belongs_to :billing_address
  accepts_nested_attributes_for :billing_address

  belongs_to :user
  belongs_to :organisation

  before_create :set_last_four_digits

  protected

  def set_last_four_digits
    self.last_four_digits = card_number.to_s[-4, 4] if card_number
  end
end
