require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe "breadcrumbs" do
    def breadcrumbs
      helper.instance_variable_get('@content_for_breadcrumbs')
    end

    before :each do
      helper.instance_variable_set('@content_for_breadcrumbs', '')
      @home_link = '<a href="/home"'
    end

    it "should wrap output in an ol" do
      helper.breadcrumbs('First', 'Second')
      breadcrumbs.should have_tag('ol')
    end

    it "should provide some breadcrumbs when organisation_page is false" do
      helper.breadcrumbs('Hello', :organisation_page => false)
      breadcrumbs.should include('>Hello</li>')
    end

    it "should not provide home link if @current_organisation isn't set" do
      helper.breadcrumbs('Hello')
      breadcrumbs.should_not include(@home_link)
    end

    describe "when @current_organisation is set" do
      before :each do
        helper.instance_variable_set('@current_organisation', 'org name')
      end

      it "should provide home link" do
        helper.breadcrumbs('Hello')
        breadcrumbs.should include(@home_link)
      end

      it "should not provide home link if organisation_page is false" do
        helper.breadcrumbs('Hello', :organisation_page => false)
        breadcrumbs.should_not include(@home_link)
      end
    end

    it "should set odd and even" do
      helper.breadcrumbs('First', 'Second')

      breadcrumbs.should have_tag('li.odd', 'First')
      breadcrumbs.should have_tag('li.even', 'Second')
    end

    it "should set last-child" do
      helper.breadcrumbs('First', 'Second')
      breadcrumbs.should have_tag('li.even.last-child', 'Second')
    end
  end

  describe "card_number" do
    it "should turn 4242 to ************4242" do
      helper.card_number(4242).should == "************4242"
    end

    it "should turn 242 to ************0242" do
      helper.card_number(242).should == "************0242"
    end
  end

  describe "story_format" do
    before :each do
      @content = "As a developer
I want stories to be formatted nicely
So that my eyes don't hurt"
    end

    it "should turn lines into list items" do
      helper.story_format(@content).should have_tag('li', 'As a developer')
    end

    it "should return nil if empty" do
      helper.story_format('').should be_nil
    end

    it "should escape html" do
      helper.story_format('<script>alert("hi")</script>').
        should_not have_tag('script')
    end
  end

  describe "render_flash" do
    describe "with no flash" do
      it "should return nil" do
        helper.render_flash.should be_nil
      end
    end

    describe "with flash notice" do
      before :each do
        flash[:notice] = 'hello'
      end

      it "should render a special div" do
        helper.render_flash.should have_tag('div[class=?]', 'flash')
      end

      it "should render a div for the type" do
        helper.render_flash.should have_tag('div[class=?]', 'notice')
      end

      it "should render a p for the message" do
        helper.render_flash.should have_tag('p', 'hello')
      end
    end

    describe "with blank message" do
      it "should not barf" do
        flash[:notice] = nil
        lambda {helper.render_flash}.should_not raise_error
      end
    end
  end

  describe "contextual_new_story_path" do
    before :each do
      @new_iteration = mock_model(Iteration, 
                                  :pending? => true,
                                  :new_record? => true)
      @pending_iteration = mock_model Iteration, :pending? => true
      @non_pending_iteration = mock_model Iteration, :pending? => false
      @project = mock_model Project
      @story = mock_model Story
    end

    it "should not use an iteration with new_record?" do
      helper.instance_variable_set('@iteration', @new_iteration)
      helper.instance_variable_set('@project', @project)
      helper.contextual_new_story_path.should == [:new, @project, :story]
    end

    it "should use a pending iteration" do
      helper.instance_variable_set('@iteration', @pending_iteration)
      helper.instance_variable_set('@project', @project)
      helper.contextual_new_story_path.should == [:new, @project, @pending_iteration, :story]
    end

    it "should not use a non-pending iteration" do
      helper.instance_variable_set('@iteration', @non_pending_iteration)
      helper.instance_variable_set('@project', @project)
      helper.contextual_new_story_path.should == [:new, @project, :story]
    end

    it "should use a project" do
      helper.instance_variable_set('@iteration', nil)
      helper.instance_variable_set('@project', @project)
      helper.contextual_new_story_path.should == [:new, @project, :story]
    end

    it "should not use a project if it is a new record" do
      @project.stub!(:new_record?).and_return(true)
      helper.instance_variable_set('@project', @project)
      helper.should_receive(:new_story_path)
      helper.contextual_new_story_path
    end

    it "should notice no project" do
      helper.instance_variable_set('@project', nil)
      helper.instance_variable_set('@iteration', nil)
      helper.should_receive(:new_story_path)
      helper.contextual_new_story_path
    end
  end

end
