require File.join(File.dirname(__FILE__), 'payment_plans')
class Organisations < ObjectMother
  truncate_organisation

  def self.organisation_prototype
    {
      :name => (Organisation.count + 1),
      :payment_plan_id => PaymentPlans.create_payment_plan!(:project_limit => 1000).id,
    }
  end

  define_organisation(:jandaweb, 
                      :name => 'Jandaweb', 
                      :payment_plan_id => PaymentPlans.create_payment_plan!(:project_limit => 1000).id)
end
