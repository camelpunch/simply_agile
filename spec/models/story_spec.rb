require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Story do
  before(:each) do
    @valid_attributes = {
      :project_id => "1",
      :iteration_id => "1",
      :name => "value for name",
      :content => "value for content"
    }
  end

  it "should create a new instance given valid attributes" do
    Story.create!(@valid_attributes)
  end

  describe "status" do
    it "should have a default value of 'pending'" do
      Story.new.status.should == 'pending'
    end
  end

  describe "acceptance_criteria" do
    it "should have the writer" do
      Story.new.should respond_to(:acceptance_criteria=)
    end
  end

  describe "assigned_or_available_for" do
    before :each do
      Story.delete_all
      @iteration = Iteration.new
      @available = Stories.create_story!(:name => 'available', 
        :iteration_id => nil)
      @unavailable = Stories.create_story!(:name => 'unavailable', 
        :iteration_id => 234)
      @stories = Story.assigned_or_available_for(@iteration)
    end

    describe "for new iteration" do
      it "should include available stories" do
        @stories.should include(@available)
      end

      it "should exclude unavailable stories" do
        @stories.should_not include(@unavailable)
      end
    end

    describe "for existing iteration" do
      before :each do
        @available_by_assignment = Story.create!(:project_id => 123,
          :content => 'asdf',
          :name => 'available by assignment')
        @iteration = Iterations.create_iteration! :stories => [@available_by_assignment]
        @stories = Story.assigned_or_available_for(@iteration)
      end

      it "should include an assigned story" do
        @stories.should include(@available_by_assignment)
      end
    end
  end

  describe "destroy" do
    it "should destroy dependent acceptance criteria" do
      Story.delete_all
      story = Story.create! @valid_attributes
      criterion = story.acceptance_criteria.create! :criterion => 'bob'
      story.destroy
      lambda {criterion.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "project" do
    it "should have the writer" do
      Story.new.should respond_to(:project=)
    end
  end

  describe "iteration" do
    it "should have the writer" do
      Story.new.should respond_to(:iteration=)
    end
  end

  describe "validations" do
    before :each do
      @story = Story.new
      @story.valid?
    end

    it "should require a name" do
      @story.errors.on(:name).should_not be_nil
    end

    it "should require a unique name within the scope of a project" do
      @story.project_id = 1
      @story.name = 'bob'
      @story.content = 'bob'
      @story.save!
      new_story = Story.new :name => 'bob'
      new_story.project_id = 1
      new_story.valid?
      new_story.errors.on(:name).should_not be_nil
    end

    it "should require content" do
      @story.errors.on(:content).should_not be_nil
    end

    it "should require a project" do
      @story.errors.on(:project_id).should_not be_nil
    end

    it "should require that an assigned iteration belongs to its project" do
      @story.stub!(:project).and_return(mock_model(Project))
      @story.stub!(:iteration).and_return(mock_model(Iteration,
          :project_id => 431314))
      @story.valid?
      @story.errors.on(:iteration_id).should_not be_nil
    end

    describe "iteration assignment" do
      it "should not be allowed if the story is already in an iteration" do
        existing = Story.create! @valid_attributes.merge(:iteration_id => 234)
        existing.iteration_id = 543
        existing.valid?
        existing.errors.on(:iteration_id).should_not be_nil
      end
    end
  end

  describe "update_status_from_acceptance_criteria" do
    before :each do
      @acs = mock('Acceptance Criteria')
      @story = Story.new
      @story.stub!(:acceptance_criteria).and_return(@acs)
    end

    describe "where all accepance criteria are completed" do
      before :each do
        @acs.stub!(:uncompleted).and_return([])
      end

      it "should change status from in progress to testing" do
        @story.stub!(:status).and_return(Story::Status::IN_PROGRESS)
        @story.should_receive(:status=).with(Story::Status::TESTING)
        @story.update_status_from_acceptance_criteria
      end

      it "should change status from pending to testing" do
        @story.stub!(:status).and_return(Story::Status::PENDING)
        @story.should_receive(:status=).with(Story::Status::TESTING)
        @story.update_status_from_acceptance_criteria
      end

      it "should not change status from complete to testing" do
        @story.stub!(:status).and_return(Story::Status::COMPLETE)
        @story.should_not_receive(:status=).with(Story::Status::TESTING)
        @story.update_status_from_acceptance_criteria
      end
    end

    describe "where not all accepance criteria are completed" do
      before :each do
        ac = mock_model(AcceptanceCriterion)
        @acs.stub!(:uncompleted).and_return([ac])
      end

      it "should change status from testing to in progress" do
        @story.stub!(:status).and_return(Story::Status::TESTING)
        @story.should_receive(:status=).with(Story::Status::IN_PROGRESS)
        @story.update_status_from_acceptance_criteria
      end

      it "should change status from complete to in progress" do
        @story.stub!(:status).and_return(Story::Status::COMPLETE)
        @story.should_receive(:status=).with(Story::Status::IN_PROGRESS)
        @story.update_status_from_acceptance_criteria
      end

      it "should not change status from pending to in progress" do
        @story.stub!(:status).and_return(Story::Status::PENDING)
        @story.should_not_receive(:status=).with(Story::Status::IN_PROGRESS)
        @story.update_status_from_acceptance_criteria
      end
    end
  end

  describe "incomplete" do
    before :all do
      @testing = Stories.create_story :status => 'testing'
      @complete = Stories.create_story :status => 'complete'
    end

    it "should respond to incomplete" do
      Story.should respond_to(:incomplete)
    end

    it "should return stories whose status is not complete" do
      Story.incomplete.should include(@testing)
    end

    it "should not return stories whose status is complete" do
      Story.incomplete.should_not include(@complete)
    end
  end
end
