class UserMother < ObjectMother
  def self.user_prototype
    {
      :name => 'some_user',
      :pet => false
    }
  end
end