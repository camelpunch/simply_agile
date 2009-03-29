require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AcceptanceCriteriaController do

  before :each do
    login
    setup_project

    @story = Stories.create_story!(
      :status => Story::Status::IN_PROGRESS,
      :project => @project
    )

    Iterations.create_iteration!(:stories => [@story], :project => @project)
    @acceptance_criterion = @story.acceptance_criteria.create!(
      :criterion => 'Some criterion'
    )
  end

  describe "it belongs to a story", :shared => true do
    it "should assign the story" do
      do_call
      assigns[:story].should == @story
    end
  end

  describe "it operates on an existing criterion", :shared => true do
    it "should assign the criterion" do
      do_call
      assigns[:acceptance_criterion].should == @acceptance_criterion
    end
  end

  describe "it operates on a new criterion", :shared => true do
    it "should build the criterion" do
      do_call
      assigns[:acceptance_criterion].should be_kind_of(AcceptanceCriterion)
    end
  end

  # set @criterion in calling block's before(:each)
  describe "it saves a criterion", :shared => true do
    before :each do
      @attributes = {'criterion' => 'asdf'}
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it belongs to a story"

    it "should attempt to save" do
      do_call
      acceptance_criterion = assigns[:acceptance_criterion]
      acceptance_criterion.reload
      acceptance_criterion.criterion.should == @attributes['criterion']
    end
    
    describe "success" do
      it "should redirect to the story page" do
        do_call
        response.should redirect_to(project_iteration_story_url(@project, 
                                                                @story.iteration, 
                                                                @story))
      end

      describe "js" do
        it "should render the new list" do
          do_call :format => 'js'
          response.should render_template('acceptance_criteria/list')
        end
      end
    end

    describe "failure" do
      before :each do
        @attributes['criterion'] = nil
      end

      describe "html" do
        it "should re-render the stories/show page" do
          do_call
          response.should render_template('stories/show')
        end
      end

      describe "js" do
        before :each do
          do_call :format => 'js'
        end

        it "should render some text" do
          response.body.should_not be_blank
        end

        it "should provide a failure response code" do
          response.code.should == '422'
        end
      end
    end
  end

  describe "instance variable setup" do
    before :each do
      controller.stub!(:params).and_return({
          :project_id => @project.id.to_s,
          :story_id => @story.id.to_s
        })
    end

    describe "get_story" do
      it "should set the story" do
        controller.instance_variable_set("@project", @project)
        controller.send(:get_story)
        controller.instance_variable_get("@story").should == @story
      end
    end

    describe "new_acceptance_criterion" do
      before :each do
        controller.stub!(:params).and_return(:acceptance_criterion => {})
        controller.instance_variable_set("@story", @story)
      end

      it "should belong to the story" do
        controller.send(:new_acceptance_criterion)
        acceptance_criterion = 
          controller.instance_variable_get("@acceptance_criterion")
        acceptance_criterion.story.should == @story
      end
    end

    describe "get_acceptance_criterion" do
      before :each do
        controller.stub!(:params).and_return(:id => @acceptance_criterion.id)
        controller.instance_variable_set("@story", @story)
      end

      it "should set the instance variable" do
        controller.send(:get_acceptance_criterion)
        controller.instance_variable_get('@acceptance_criterion').
          should == @acceptance_criterion
      end
    end
  end

  describe "create" do
    def do_call(params = {})
      post :create, {
        :project_id => @project.id, 
        :story_id => @story.id,
        :acceptance_criterion => @attributes 
      }.merge(params)
    end

    it_should_behave_like "it operates on a new criterion"
    it_should_behave_like "it saves a criterion"
    it_should_behave_like "it sets the current user"
  end

  describe "destroy" do
    def do_call(params = {})
      delete :destroy, {
        :id => @acceptance_criterion.id,
        :project_id => @project.id, 
        :story_id => @story.id
      }.merge(params)
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it belongs to a story"
    it_should_behave_like "it sets the current user"

    it "should destroy the acceptance criterion" do
      do_call
      AcceptanceCriterion.find_by_id(@acceptance_criterion.id).should be_nil
    end

    describe "html" do
      it "should redirect to the story page" do
        do_call
        response.should redirect_to(project_iteration_story_url(@project, 
                                                                @story.iteration, 
                                                                @story))
      end
    end

    describe "js" do
      it "should render the criteria partial" do
        do_call :format => 'js'
        response.should render_template('acceptance_criteria/list')
      end
    end
  end

  describe "edit" do
    def do_call
      get :edit, :id => @acceptance_criterion.id,
        :project_id => @project.id, :story_id => @story.id
    end

    it_should_behave_like "it belongs to a project"
    it_should_behave_like "it belongs to a story"
    it_should_behave_like "it's successful"

    it_should_behave_like "it operates on an existing criterion" 
    it_should_behave_like "it sets the current user"
  end

  describe "update" do
    def do_call(params = {})
      put :update,
        {:id => @acceptance_criterion.id,
        :project_id => @project.id, :story_id => @story.id,
        :acceptance_criterion => @attributes}.merge(params)

    end

    before :each do
      @story = Stories.create_story!(
        :status => Story::Status::IN_PROGRESS,
        :project => @project
      )

      Iterations.create_iteration!(:stories => [@story], :project => @project)
      @acceptance_criterion = @story.acceptance_criteria.create!(
        :criterion => 'Some criterion'
      )
    end

    it_should_behave_like "it operates on an existing criterion" 
    #    it_should_behave_like "it saves a criterion"
    it_should_behave_like "it sets the current user"
    
    describe "js" do
      describe "success" do
        before :each do
          @attributes = {:complete => 'true'}
          @acceptance_criterion.stub!(:update_attributes).and_return(true)
          @story.stub!(:status).and_return('gets', 'changed')
          controller.stub!(:get_story)
          controller.instance_variable_set("@story", @story)
        end

        it "should return success code" do
          do_call :format => 'js'
          response.should be_success
        end

        it "should set the text" do
          do_call :format => 'js'
          response.body.should_not be_blank
        end

        it "should not use flash" do
          controller.should_not_receive(:flash)
        end
      end
    end

    describe "setting a flash notice if the story status changes" do
      before :each do
        controller.instance_eval { flash.stub!(:sweep) }
      end

      it "should set flash notice when the last acceptance criterion is completed" do
        AcceptanceCriterion.with_observers(:acceptance_criterion_observer) do
          put :update,
            :id => @acceptance_criterion.id,
            :project_id => @story.project.id,
            :story_id => @story.id,
            :acceptance_criterion => { :complete => true }
          flash[:notice].should_not be_blank
        end
      end

      it "should set flash notice when first acceptance criterion is uncompleted" do
        @acceptance_criterion.update_attributes!(:fulfilled_at => Time.now)
        @story.update_attributes!(:status => Story::Status::TESTING)

        AcceptanceCriterion.with_observers(:acceptance_criterion_observer) do
          put :update,
            :id => @acceptance_criterion.id,
            :project_id => @story.project.id,
            :story_id => @story.id,
            :acceptance_criterion => { :complete => false }
          flash[:notice].should_not be_blank
        end
      end

      it "should not set flash notice when one of many acceptance criterion is completed" do
        @story.acceptance_criteria.create!(
          :criterion => 'Some other criterion'
        )
        put :update,
          :id => @acceptance_criterion.id,
          :project_id => @story.project.id,
          :story_id => @story.id,
          :acceptance_criterion => { :complete => true }
        flash[:notice].should be_blank
      end

      it "should not set flash notice when acceptance criterion are uncompleted and story status is in progress" do
        @acceptance_criterion.update_attributes(:fulfilled_at => Time.now)
        put :update,
          :id => @acceptance_criterion.id,
          :project_id => @project.id,
          :story_id => @story.id,
          :acceptance_criterion => { :complete => false }
        flash[:notice].should be_blank
      end
    end
  end
end
