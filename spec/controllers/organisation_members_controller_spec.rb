require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationMembersController do
  before :each do
    login
  end

  describe "index" do
    def do_call
      get :index, :organisation_id => @organisation.id
    end
    
    it_should_behave_like "it's successful"

    it "should assign the organisation" do
      do_call
      assigns[:organisation].should == @organisation
    end

    it "should assign a new organisation member" do
      do_call
      assigns[:organisation_member].should be_kind_of(OrganisationMember)
      assigns[:organisation_member].should be_new_record
    end
  end

  describe "create" do
    def do_call
      post(:create, 
           :organisation_id => @organisation.id, 
           :organisation_member => @user_params)
    end

    before :each do
      @user_params = { "email_address" => 'user@jandaweb.com' }
    end

    it "should redirect to the organisation members page" do
      do_call
      response.should redirect_to(organisation_members_url(@organisation))
    end

    describe "with an existing user" do
      before :each do
        @user = Users.create_user!(
          :email_address => @user_params['email_address']
        )
      end

      it "should assign the user" do
        do_call
        assigns[:user].should == @user
      end
    end

    describe "without an existing user" do
      before :each do
        User.delete_all(@user_params)
      end

      it "should create a new user" do
        user_count = User.count
        do_call
        User.count.should == user_count + 1
      end

      it "should set the user email address" do
        do_call
        @user = User.find(:first, :order => 'id DESC')
        @user.email_address.should == @user_params['email_address']
      end

      it "should assign the new user" do
        do_call
        @user = User.find(:first, :order => 'id DESC')
        assigns[:user].should == @user
      end
    end

    describe "OrganisationMember" do
      before :each do
        @organisation_member_count = OrganisationMember.count
        do_call
        @organisation_member =
          OrganisationMember.find(:first, :order => 'id desc')
      end

      it "should be created" do
        OrganisationMember.count.should == @organisation_member_count + 1
      end

      it "should have the organisation set" do
        @organisation_member.organisation.should == @organisation
      end

      it "should have the user set" do
        @organisation_member.user.should == assigns[:user]
      end

      it "should have the sponsor set" do
        @organisation_member.sponsor.should == @user
      end
    end

    describe "when a member creation fails" do
      before :each do
        @user = Users.create_user!(
          :email_address => @user_params['email_address']
        )
        @organisation.organisation_members.create!(:user => @user)

        @organisation_member_count = OrganisationMember.count
        do_call
      end

      it "should not create a new organisation member" do
        OrganisationMember.count.should == @organisation_member_count
      end

      it "should display the 'index' page" do
        response.should render_template('organisation_members/index')
      end

      it "should assign the organisation member" do
        assigns[:organisation_member].should be_an(OrganisationMember)
      end
    end
  end

    describe "destroy" do
      def do_call
        delete :destroy, :organisation_id => @organisation.id,
          :id => @new_user.id
      end
  
      before :each do
        @new_user = Users.create_user!
        @organisation.organisation_members.create!(:user => @new_user)
      end
  
      it "should assign the user" do
        do_call
        assigns[:user].should == @new_user
      end
  
      it "should remove the user from the organisation" do
        do_call
        @new_user.reload
        @new_user.organisations.should_not include(@organisation)
      end
  
      it "should redirect to the organisation members page" do
        do_call
        response.should redirect_to(organisation_members_url(@organisation))
      end
    end
end
