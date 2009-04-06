class Payments < ObjectMother
  truncate_payment
  def self.payment_prototype
    {
      :organisation => Organisations.create_organisation!
    }
  end
end
