class PaymentMethods < ObjectMother
  def self.payment_method_prototype
    {
      :cardholder_name => 'Joe Bloggs',
      :number => '4929000000006',
      :month => 1.month.from_now.month,
      :year => 1.month.from_now.year,
      :verification_value => 123,
      :card_type => 'visa'
    }
  end
end
