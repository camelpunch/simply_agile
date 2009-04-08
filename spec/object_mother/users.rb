require 'vendor/plugins/validates_email_format_of/lib/validates_email_format_of'
class Users < ObjectMother
  truncate_user
  def self.user_prototype
    user_count = User.count
    organisation_count = Organisation.count
    {
      :email_address => "user#{user_count + 1}@jandaweb.com",
      :password => 'password',
      :organisations => [Organisations.create_organisation!(:name => "Organisation #{organisation_count}")]
    }
  end
end
