require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Iteration do
  before(:each) do
    @story = mock_model(Story, :valid? => true, :[]= => nil, :save => nil)
    @valid_attributes = {
      :name => "value for name",
      :duration => "1",
      :started_on => Date.today,
      :finished_on => Date.today,
      :stories => [@story],
    }
  end

  it "should create a new instance given valid attributes" do
    iteration = Iteration.new
    iteration.project_id = 1
    iteration.update_attributes!(@valid_attributes)
  end

  describe "default name" do
    it "should use a default name if none is assigned" do
      project = Project.create(:name => "woo")
      iteration = project.iterations.build
      iteration.name.should == "Iteration #{project.iterations.count + 1}"
    end
    
    it "should use the assigned name if available" do
      name = "Iteration Name"
      project = Project.create(:name => "woo")
      iteration = project.iterations.build(:name => name)
      iteration.name.should == name
    end
  end

  describe "attribute protection" do
    it "should prevent project_id from being mass-assigned" do
      iteration = Iteration.new(:name => 'asdf',
        :duration => 1,
        :project_id => 132)
      iteration.project_id.should be_blank
    end
  end

  describe "project" do
    it "should provide the writer" do
      Iteration.new.should respond_to(:project=)
    end
  end

  describe "stories" do
    it "should provide the writer" do
      Iteration.new.should respond_to(:stories=)
    end
  end

  describe "validations" do
    before :each do
      @iteration = Iteration.new
      @iteration.valid?
    end

    it "should require a name" do
      @iteration.errors.on(:name).should_not be_nil
    end

    it "should require a duration" do
      @iteration.errors.on(:duration).should_not be_nil
    end

    it "should require a project" do
      @iteration.errors.on(:project_id).should_not be_nil
    end

    it "should require some stories" do
      @iteration.errors.on(:stories).should_not be_nil
    end
  end
end
