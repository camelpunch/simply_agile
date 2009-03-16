# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require File.join(File.dirname(__FILE__), 'matchers', 'association_matchers')

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
  config.include ValidateXhtml
  config.include AssociationMatchers

  def login
    @organisation = mock_model Organisation
    @user = mock_model User, :organisation => @organisation
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:current_user).and_return(@user)
  end

  def stub_projects!
    @project = mock_model(Project, :organisation_id => @organisation.id)
    @projects = mock('Collection', :empty? => false)
    @projects.stub!(:find).with(@project.id.to_s).and_return(@project)
    @organisation.stub!(:projects).and_return(@projects)
  end

  describe "it belongs to a project", :shared => true do
    it "should assign the project" do
      controller.should_receive(:get_project)
      do_call
    end
  end

  describe "it's successful", :shared => true do
    it "should respond with success" do
      do_call
      response.should be_success
    end
  end

  describe "a standard view", :shared => true do
    it "should be successful" do
      response.should be_success
    end

    it "should be valid" do
      response.should be_valid_xhtml   
    end
  end

  describe "guidance", :shared => true do
    it_should_behave_like "a standard view"

    it "should provide guidance" do
      assigns[:body_classes].should include('guidance')
    end
  end
end

class ActiveRecord::Base
  def <=>(other)
    self.id <=> other.id
  end
end
