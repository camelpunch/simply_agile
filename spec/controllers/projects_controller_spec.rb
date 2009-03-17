require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do
  before :each do
    login
    @project = mock_model Project
    @new_project = mock_model Project
    @projects = mock('Collection', :build => @new_project, :find => @project)
    @user.organisation.stub!(:projects).and_return(@projects)
  end

  describe "get_project" do
    it "should restrict to user's projects" do
      controller.stub!(:params).and_return({:id => @project.id.to_s})
      @projects.stub!(:find).with(@project.id.to_s).and_return(@project)
      controller.send(:get_project)
      controller.instance_variable_get("@project").should == @project
    end
  end

  describe "new_project" do
    before :each do
      controller.stub!(:params).and_return({})
    end

    it "should set the organisation from the user" do
      @projects.should_receive(:build)
      controller.send(:new_project)
    end

    it "should set the instance variable" do
      controller.send(:new_project)
      controller.instance_variable_get("@project").should == @new_project
    end
  end
  
  describe "index" do
    def do_call
      get :index
    end

    it_should_behave_like "it's successful"
  end

  describe "new" do
    def do_call
      get :new
    end
    
    it_should_behave_like "it's successful"

    it "should assign a new project" do
      controller.should_receive(:new_project)
      do_call
    end
  end

  describe "create" do
    def do_call
      post :create, :project => @attributes
    end

    before :each do
      @attributes = {'name' => 'some name'}
    end

    it "should attempt to save" do
      @new_project.should_receive(:update_attributes).with(@attributes)
      do_call
    end

    describe "success" do
      before :each do
        @new_project.stub!(:update_attributes).with(@attributes).
          and_return(true)
      end

      it "should redirect to project page" do
        do_call
        response.should redirect_to(project_url(@new_project))
      end

      it "should provide a flash notice" do
        do_call
        flash[:notice].should_not be_blank
      end
    end

    describe "failure" do
      before :each do
        @new_project.stub!(:update_attributes).with(@attributes).
          and_return(false)
      end

      it "should re-render the new template" do
        do_call
        response.should render_template('projects/new')
      end
    end
  end

  describe "show" do
    def do_call
      get :show, :id => @project.id
    end

    before :each do
      Project.stub!(:find).with(@project.id.to_s).and_return(@project)
      @project.stub!(:stories).and_return([@story])
      controller.stub!(:get_project)
      controller.instance_variable_set('@project', @project)
    end

    it_should_behave_like "it's successful"

    it "should assign the project" do
      controller.should_receive(:get_project)
      do_call
    end

    describe "with no stories" do
      before :each do
        @project.stub!(:stories).and_return([])
      end

      it "should render the guidance template" do
        do_call
        response.should render_template('projects/show_guidance')
      end
    end
  end

  describe "edit" do
    def do_call
      get :edit, :id => @project.id
    end

    before :each do
      Project.stub!(:find).with(@project.id.to_s).and_return(@project)
    end

    it_should_behave_like "it's successful"

    it "should assign the project" do
      controller.should_receive(:get_project)
      do_call
    end
  end

  describe "update" do
    def do_call(params = {})
      put :update, {:id => @project.id, :project => @attributes}.merge(params)
    end

    before :each do
      @attributes = {'name' => 'some new name'}
      controller.instance_variable_set('@project', @project)
      @project.stub!(:update_attributes)
    end

    it "should assign the project" do
      controller.should_receive(:get_project)
      do_call
    end

    it "should attempt to save" do
      @project.should_receive(:update_attributes).with(@attributes)
      do_call
    end

    describe "success" do
      before :each do
        @project.stub!(:update_attributes).with(@attributes).
          and_return(true)
      end

      describe "html" do
        it "should redirect to project page" do
          do_call
          response.should redirect_to(project_url(@project))
        end

        it "should provide a flash notice" do
          do_call
          flash[:notice].should_not be_blank
        end
      end

      describe "js" do
        it "should be successful" do
          do_call(:format => 'js')
          response.should be_success
        end
      end
    end

    describe "failure" do
      before :each do
        @project.stub!(:update_attributes).with(@attributes).
          and_return(false)
      end

      it "should re-render the new template" do
        do_call
        response.should render_template('projects/edit')
      end
    end
  end
end
