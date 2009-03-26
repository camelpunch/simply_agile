require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/home/show" do
  before :each do
    @user = mock_model User, :organisation => 'asdf'
    assigns[:current_user] = @user

    @active_iterations = []
    assigns[:active_iterations] = @active_iterations
  end

  describe "with projects" do
    before(:each) do
      @user.stub!(:projects).and_return([mock_model(Project)])
      render 'home/show'
    end

    it_should_behave_like "a standard view"
  end

  describe "with no projects" do
    before :each do
      @user.stub!(:projects).and_return([])
      render 'home/show'
    end

    it_should_behave_like "a standard view"

    it "should provide a link to projects/new" do
      response.should have_tag('a[href=?]', new_project_path)
    end
  end

  describe "with active iterations" do
    before :each do
      @project = mock_model(Project)
      @active_iteration = mock_model(Iteration,
                                     :name => '',
                                     :project => @project,
                                     :pending? => false
                                   )
      assigns[:active_iterations] = [@active_iteration]
      render 'home/show'
    end

    it_should_behave_like "a standard view"
  end
end
