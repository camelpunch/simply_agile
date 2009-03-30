require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = User.new
  end

  it "should create a new instance given valid attributes" do
    Users.create_user!
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
    it "should have many organisation_members" do
      User.should have_many(:organisation_members)
    end

    it "should have many organisations" do
      User.should have_many(:organisations)
    end

    it "should have many story_actions" do
      User.should have_many(:story_actions)
    end

    it "should have many iterations_worked_on" do
      User.should have_many(:iterations_worked_on)
    end
  end

  describe "active work" do
    before :each do
      @user = Users.create_user!
      @project = Projects.create_project!

      @worked_on_story = Stories.create_story!(:project => @project)
      @iteration = Iterations.create_iteration!(
        :name => "Active, worked on",
        :project => @project,
        :stories => [@worked_on_story],
        :duration => 2
      )
      @iteration.start
      @user.story_actions.create!(
        :iteration => @iteration, :story => @worked_on_story
      )

      @inactive_worked_on_story = Stories.create_story!(:project => @project)
      @inactive_iteration = Iterations.create_iteration!(
        :name => "Inactive, worked on",
        :project => @project,
        :stories => [@inactive_worked_on_story],
        :duration => 1,
        :start_date => 2.days.ago
      )
      @user.story_actions.create!(
        :iteration => @inactive_iteration,
        :story => @inactive_worked_on_story
      )

      @unworked_on_story = Stories.create_story!(:project => @project)
      @not_worked_on_iteration = Iterations.create_iteration!(
        :name => "not worked on",
        :project => @project,
        :stories => [@unworked_on_story]
      )

      @other_organisation = @user.organisations.create!(:name => 'other')
      @other_project = @other_organisation.projects.create!(:name => 'other')
      @other_story = Stories.create_story!(:project => @project)
      @other_iteration = Iterations.create_iteration!(
        :name => "Active, worked on",
        :project => @other_project,
        :stories => [@other_story],
        :duration => 2
      )
      @other_iteration.start
      @user.story_actions.create!(
        :iteration => @other_iteration,
        :story => @other_story
      )
    end

    describe "active_iterations_worked_on" do
      it "should return a unique set of iterations" do
        @user.story_actions.first.clone.save!
        iterations = @user.active_iterations_worked_on(@organisation)
        unique_iterations = iterations.uniq
        iterations.should == unique_iterations
      end

      it "should return iterations for the stories worked on" do
        @user.active_iterations_worked_on(@organisation).
          should include(@iteration)
      end

      it "should not return iterations that are not active" do
        @user.active_iterations_worked_on(@organisation).
          should_not include(@inactive_iteration)
      end

      it "should not return iterations that the user has no actions for" do
        @user.active_iterations_worked_on(@organisation).
          should_not include(@iteration_not_worked_on)
      end

      it "should not return iterations for other organisations" do
        @user.active_iterations_worked_on(@organisation).
          should_not include(@other_story)
      end
    end

    describe "active_stories_worked_on" do
      it "should return stories for active iterations" do
        @user.active_stories_worked_on(@organisation).
          should include(@worked_on_story)
      end

      it "should not return stories for inactive iterations" do
        @user.active_stories_worked_on(@organisation).
          should_not include(@inactive_worked_on_story)
      end

      it "should not return stories with no actions" do
        @user.active_stories_worked_on(@organisation).
          should_not include(@unworked_on_story)
      end

      it "should not return stories for other organisation" do
        @user.active_stories_worked_on(@organisation).
          should_not include(@other_story)
      end
    end
  end

  describe "projects" do
    before :each do
      @user = Users.create_user!
      @users_projects = []

      @organisation1 = Organisations.create_organisation!
      @organisation1.organisation_members.create!(:user => @user)
      @users_projects << @organisation1.projects.create!(:name => 'project1')

      @organisation2 = Organisations.create_organisation!
      @organisation2.organisation_members.create!(:user => @user)
      @users_projects << @organisation2.projects.create!(:name => 'project2')

      @organisation3 = Organisations.create_organisation!
      @organisation3.projects.create!(:name => "someone else's project")

    end

    it "should return projects which belong to the user's organisations" do
      @user.projects.should == @users_projects
    end

    it "should have many story team members" do
      User.should have_many(:story_team_members)
    end

    it "should have many stories" do
      User.should have_many(:stories)
    end
  end

  describe "creation" do
    describe "on signup" do
      before(:each) do
        @user = User.new(Users.user_prototype)
        @user.signup = true
      end

      it "should create a new organisation for the user" do
        @user.organisation_name = 'New Organisation'
        @user.save
        Organisation.find_by_name('New Organisation').should_not be_nil
      end

      it "should encrypt the password" do
        @user.password = 'some password'
        @user.save
        @user.encrypted_password.should == Digest::SHA1.hexdigest('some password')
      end

      describe "verification token" do
        it "should be generated when a user is created" do
          @user.save
          @user.verification_token.should_not be_nil
        end

        it "should not generate the same token" do
          @user.save
          new_user = Users.create_user!
          @user.verification_token.should_not == new_user.verification_token
        end
      end
    end

    describe "on being added to an organisation" do
      it "should be verified" do
        @user = Users.create_user!
        @user.should be_verified
      end
    end
  end

  describe "password=" do
    it "should have the writer" do
      User.new.should respond_to(:password=)
    end
  end

  describe "validations" do
    before :each do
      User.delete_all
      @user = User.new(Users.user_prototype)
    end
    
    describe "email address" do
      before :each do
        @user.email_address = nil
      end

      it "should require an email address" do
        @user.valid?
        @user.errors.invalid?(:email_address).should be_true
      end

      it "should not allow invalid email addresses" do
        @user.email_address = "this is not an email address"
        @user.valid?
        @user.errors.invalid?(:email_address).should be_true
      end

      it "should allow valid email addresses" do
        @user.email_address = "user@jandaweb.com"
        @user.valid?
        @user.errors.invalid?(:email_address).should be_false
      end

      it "should not allow duplicate email addresses" do
        email_address = "user@jandaweb.com"
        Users.create_user!(:email_address => email_address)
        @user.email_address = email_address
        @user.valid?
        @user.errors.invalid?(:email_address).should be_true
      end
    end

    describe "password" do
      before :each do
        @user.password = nil
      end
      
      it "should require a password on signup" do
        @user.signup = true
        @user.valid?
        @user.errors.invalid?(:password).should be_true
      end

      it "should not require a password if the user is being added to an organisation" do
        @user.stub!(:signup?).and_return(false)
        @user.valid?
        @user.errors.invalid?(:password).should be_false
      end

      it "should not require a password if the encrypted password is set" do
        @user.encrypted_password = 'hashed password'
        @user.valid?
        @user.errors.invalid?(:password).should be_false
      end
    end
  end

  describe "valid" do
    it "should not return users with verify_by in the past" do
      unverified_user = Users.create_user!(:verify_by => 1.day.ago)
      User.valid.should_not include(unverified_user)
    end

    it "should return users with verify_by in the future" do
      user_with_time_left = Users.create_user!(:verify_by => 1.day.from_now)
      User.valid.should include(user_with_time_left)

    end

    it "should return users with verify_by set to nil" do
      verified_user = Users.create_user!
      verified_user.update_attributes(:verify_by => nil)
      User.valid.should include(verified_user)
    end
  end

  describe "verification" do
    before :each do
      @user = Users.create_user!(:signup => true)
    end

    it "should not be verified by default" do
      @user.verified.should be_false
    end

    it "should set verify_by on a new user" do
      @user.verify_by.should == Date.today + 7
    end

    describe "verify" do
      describe "with the correct token" do
        before :each do
          @response = @user.verify(:token => @user.verification_token)
          @user.reload
        end

        it "should return true" do
          @response.should be_true
        end

        it "should verify the user" do
          @user.should be_verified
        end

        it "should clear the verify_by date" do
          @user.verify_by.should be_nil
        end
      end

      describe "with an incorrect token" do
        before :each do
          @response = @user.verify(:token => 'wrong token')
          @user.reload
        end

        it "should return false" do
          @response.should be_false
        end

        it "should not verify the user" do
          @user.should_not be_verified
        end

        it "should not clear the verify_by date" do
          @user.verify_by.should_not be_nil
        end
      end
    end
  end

  describe "acknowledged_for" do
    before :each do
      @user = Users.create_user!
      @organisation = Organisations.create_organisation!
      @organisation_member =
        @organisation.organisation_members.create!(:user => @user)
    end

    it "should be false if the user does not belong to the organisation" do
      alternative_organisation = Organisations.create_organisation!
      @user.should_not be_acknowledged_for(alternative_organisation)
    end

    it "should be false if the acknowledgement token exists" do
      @user.should_not be_acknowledged_for(@organisation)
    end


    it "should be true otherwise" do
      @organisation_member.acknowledgement_token = nil
      @organisation_member.save
      @user.should be_acknowledged_for(@organisation)
    end
  end

  describe "acknowledge" do
    before :each do
      @sponsor = Users.create_user!
      @user = Users.create_user!
      @organisation = @sponsor.organisations.first
      @organisation_member =
        @organisation.organisation_members.create!(
        :user => @user,
        :sponsor => @sponsor
      )
    end

    describe "with valid token and password" do
      before :each do
        @password = 'some new password'
        @response = @user.acknowledge(
          :token => @organisation_member.acknowledgement_token,
          :password => @password
        )
        @user.reload
      end

      it "should set acknowledgement_token to nil" do
        @organisation_member.reload
        @organisation_member.acknowledgement_token.should be_nil
      end

      it "should update the password" do
        @user.encrypted_password.should == Digest::SHA1.hexdigest(@password)
      end

      it "should verify the account" do
        @user.should be_verified
      end

      it "should return true" do
        @response.should be_true
      end
    end

    describe "with invalid token" do
      before :each do
        @password = 'some new password'
        @response = @user.acknowledge(
          :token => 'wjiefoafew',
          :password => @password
        )
        @user.reload
      end

      it "should not set acknowledgement_token to nil" do
        @organisation_member.reload
        @organisation_member.acknowledgement_token.should_not be_nil
      end

      it "should not update the password" do
        @user.encrypted_password.should be_nil
      end

      it "should return false" do
        @response.should be_false
      end
    end

    describe "with no password" do
      before :each do
        @response = @user.acknowledge(
          :token => @organisation_member.acknowledgement_token,
          :password => ''
        )
        @user.reload
      end

      it "should not set acknowledgement_token to nil" do
        @organisation_member.reload
        @organisation_member.acknowledgement_token.should_not be_nil
      end

      it "should update the password" do
        @user.encrypted_password.should be_nil
      end

      it "should return false" do
        @response.should be_false
      end
    end
  end
end
