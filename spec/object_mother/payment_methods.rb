class PaymentMethods < ObjectMother
  def self.payment_method_prototype
    {
      :card_number => 1111222233334444,
      :expiry_month => 1,
      :expiry_year => 10
    }
  end
end