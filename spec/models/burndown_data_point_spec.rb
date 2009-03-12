require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BurndownDataPoint do
  before(:each) do
    @valid_attributes = {
      :iteration_id => 1,
      :story_points => 1,
      :date => Date.today
    }
  end

  it "should create a new instance given valid attributes" do
    BurndownDataPoint.create!(@valid_attributes)
  end

  describe "associations" do
    it "should belong to an iteration" do
      BurndownDataPoint.should belong_to(:iteration)
    end
  end

  describe "find_all_for_iteration" do
    before :each do
      @iteration = Iterations.create_iteration
      @different_iteration = Iterations.create_iteration

      @data_points_for_iteration = []

      4.times do |count|
        b = BurndownDataPoints.create_burndown_data_point(
          :iteration => @iteration,
          :date => count.days.ago
        )
        @data_points_for_iteration << b
      end
    end

    it "should return all data points for to an iteration in date order" do
      BurndownDataPoint.for_iteration(@iteration).should ==
        @data_points_for_iteration.reverse
    end
  end
end