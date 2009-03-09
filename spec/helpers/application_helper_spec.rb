require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

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
  end

end
