class Users < ObjectMother
  def self.user_prototype
    user_count = User.count
    organisation_count = Organisation.count
    {
      :email_address => "user#{user_count + 1}@jandaweb.com",
      :password => 'password',
      :organisation_name => "Organisation #{organisation_count}"
    }
  end
end
