require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AcceptanceCriterionObserver do
  it "should call update status on the story if completion changes" do
    @story = mock_model(Story)
    @ac = mock_model(AcceptanceCriterion, :story => @story)
    @obs = AcceptanceCriterionObserver.instance

    @story.should_receive(:update_status_from_acceptance_criteria)
    @obs.after_save(@ac)
  end
end
