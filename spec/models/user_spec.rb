require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :email_address => "value for email_address",
      :encrypted_password => "value for encrypted_password",
      :organisation_id => "1"
    }

    @user = User.new
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  describe "find_by_email_address_and_password" do
    def do_call
      User.find_by_email_address_and_password(@email_address, @password)
    end

    before :each do
      @email_address = 'some@ddress.com'
      @password = 'somepassword'
      @encrypted_password = 'someencryptedpassword'
      Digest::SHA1.stub!(:hexdigest).with(@password).and_return(@encrypted_password)
      User.stub!(:find_by_email_address_and_encrypted_password).
        with(@email_address, @encrypted_password).
        and_return(@user)
    end

    it "should find by email address and encrypted password" do
      User.should_receive(:find_by_email_address_and_encrypted_password).
        with(@email_address, @encrypted_password)
      do_call
    end

    it "should return the results of the find" do
      do_call.should == @user
    end
  end

  describe "associations" do
    it "should belong to an organisation" do
      User.should belong_to(:organisation)
    end

    it "should have many projects" do
      User.should have_many(:projects)
    end
  end

  describe "creation" do
    it "should create a new organisation for the user" do
      Users.create_user!(:organisation_name => 'New Organisation')
      Organisation.find_by_name('New Organisation').should_not be_nil
    end

    it "should encrypt the password" do
      user = Users.create_user!(:password => 'some password')
      user.encrypted_password.should == Digest::SHA1.hexdigest('some password')
    end
  end

  describe "password=" do
    it "should have the writer" do
      User.new.should respond_to(:password=)
    end
  end

  describe "validations" do
    before :each do
      @user = User.new
      @user.valid?
    end

    it "should require an organisation id" do
      @user.errors.on(:organisation).should_not be_nil 
    end
  end
end
