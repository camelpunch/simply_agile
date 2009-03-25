require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

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

    it "should notice no project" do
      helper.instance_variable_set('@project', nil)
      helper.instance_variable_set('@iteration', nil)
      helper.should_receive(:new_story_path)
      helper.contextual_new_story_path
    end
  end

end
