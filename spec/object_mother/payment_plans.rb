class PaymentPlans < ObjectMother
  truncate_payment_plan

  def self.payment_plan_prototype
    {
      :name => 'protototo',
      :price => 25
    }
  end

end
