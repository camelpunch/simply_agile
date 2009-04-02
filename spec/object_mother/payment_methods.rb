class PaymentMethods < ObjectMother
  def self.payment_method_prototype
    {
      :cardholder_name => 'Joe Bloggs',
      :card_number => '4929000000006',
      :expiry_month => 1,
      :expiry_year => 2010,
      :cv2 => 123,
      :card_type => 'visa'
    }
  end
end