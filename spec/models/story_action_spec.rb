require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryAction do
  describe "associations" do
    it "should belong to a user" do
      StoryAction.should belong_to(:user)
    end

    it "should belong to a story" do
      StoryAction.should belong_to(:story)
    end

    it "should belong to an iteration" do
      StoryAction.should belong_to(:iteration)
    end
  end
end
