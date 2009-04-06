class BillingAddresses < ObjectMother
  truncate_billing_address
  def self.billing_address_prototype
    {
      :name => 'asdf',
      :telephone_number => '123123',
      :country => 'asdf',
      :postcode => 'se22 8gb',
      :address_line_1 => 'asdf',
      :town => 'asdf',
    }
  end
end
