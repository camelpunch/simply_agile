class PaymentPlans < ObjectMother
  truncate_payment_plan

  def self.payment_plan_prototype
    {
      :name => 'protototo',
      :price => 25,
      :project_limit => 2,
      :active_iteration_limit => 2,
    }
  end

end
