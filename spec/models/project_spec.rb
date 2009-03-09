require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :organisation_id => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    Project.create!(@valid_attributes)
  end

  describe "protection" do
    it "should protect organisation_id from being mass-assigned" do
      project = Project.new(:name => 'asdf',
                            :organisation_id => 132)
      project.organisation_id.should be_blank
    end
  end

  describe "destroy" do
    before :each do
      @project = Project.create! @valid_attributes
      @iteration = @project.iterations.build :name => 'asdf', :duration => 1
      @iteration.stories.stub!(:empty?).and_return(false)
      @iteration.save!
      @story = @project.stories.build(:name => 'asdf', :content => 'asdf')
      @story.save!
    end

    it "should destroy iterations" do
      @project.destroy
      lambda {@iteration.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should destroy stories" do
      @project.destroy
      lambda {@story.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "iterations" do
    it "should have the writer" do
      Project.new.should respond_to(:iterations=)
    end
  end

  describe "organisation" do
    it "should have the writer" do
      Project.new.should respond_to(:organisation=)
    end
  end

  describe "stories" do
    it "should have the writer" do
      Project.new.should respond_to(:stories=)
    end
  end
end
