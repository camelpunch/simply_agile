class Organisations < ObjectMother
  truncate_organisation

  def self.organisation_prototype
    {
      :name => (Organisation.count + 1),
      :payment_plan_id => 1,
    }
  end

  define_organisation(:jandaweb, :name => 'Jandaweb')
end
