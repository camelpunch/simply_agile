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

  describe "organisation" do
    it "should have the writer" do
      User.new.should respond_to(:organisation=)
    end
  end

  describe "password=" do
    it "should have the writer" do
      User.new.should respond_to(:password=)
    end
  end

  describe "projects" do
    it "should have the writer" do
      User.new.should respond_to(:projects=)
    end
  end

  describe "validations" do
    before :each do
      @user = User.new
      @user.valid?
    end

    it "should require an organisation id" do
      @user.errors.on(:organisation_id).should_not be_nil 
    end
  end
end
