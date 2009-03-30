require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AcceptanceCriterionObserver do
  describe "completion change" do
    before :each do
      @story = mock_model(Story,
                          :current_user= => nil,
                          :update_status_from_acceptance_criteria => nil)
      @ac = mock_model(AcceptanceCriterion, 
                       :story => @story,
                       :current_user => nil)
      @obs = AcceptanceCriterionObserver.instance
    end

    it "should copy the current_user to the story" do
      @current_user = mock_model(User)
      @ac.stub!(:current_user).and_return(@current_user)
      @story.should_receive(:current_user=).with(@current_user)
      @obs.after_save(@ac)
    end

    it "should call update status on the story" do
      @story.should_receive(:update_status_from_acceptance_criteria)
      @obs.after_save(@ac)
    end
  end
end
