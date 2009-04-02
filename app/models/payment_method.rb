class PaymentMethod < ActiveRecord::Base
  attr_accessor :cardholder_name
  attr_accessor :card_number
  attr_accessor :cv2
  attr_accessor :card_type

  belongs_to :billing_address
  accepts_nested_attributes_for :billing_address

  belongs_to :user
  belongs_to :organisation

  before_create :set_last_four_digits

  CARD_TYPES = ['mastercard', 'visa']

  def has_expired?
    today = Date.today
    Date.new(expiry_year, expiry_month) < Date.new(today.year, today.month)
  end

  def credit_card
    @credit_card ||= create_credit_card
  end

  def credit_card
    (first_name, last_name) = cardholder_name.split(/\s/, 2) if cardholder_name
    ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => expiry_month,
      :year => expiry_year,
      :verification_value => cv2,
      :first_name => first_name,
      :last_name => last_name,
      :type => card_type
    )
  end

  protected

  def set_last_four_digits
    self.last_four_digits = credit_card.last_digits if credit_card
  end
end
