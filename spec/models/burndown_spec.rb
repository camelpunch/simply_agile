require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Burndown do
  before :each do
    @iteration = Iteration.new
    @burndown = Burndown.new(@iteration)
  end

  describe "new" do
    it "should store the iteration" do
      burndown = Burndown.new(@iteration, {})
      burndown.instance_variable_get("@iteration").should == @iteration
    end

    it "should store the width" do
      burndown = Burndown.new(@iteration, :width => 300)
      burndown.width.should == 300
    end

    it "should default the width to 600" do
      burndown = Burndown.new(@iteration, {})
      burndown.width.should == 600
    end

    it "should allow a maximum width of 600" do
      burndown = Burndown.new(@iteration, :width => '1000000')
      burndown.width.should == 600
    end
  end

  describe "baseline data" do
    it "should return story points for each day of the iteration" do
      @iteration.stub!(:duration).and_return(7)
      @iteration.stub!(:initial_estimate).and_return(300)
      @burndown.baseline_data.should == [300, 250, 200, 150, 100, 50, 0]
    end

    it "should cope with a low story point -> day ratio" do
      @iteration.stub!(:duration).and_return(9)
      @iteration.stub!(:initial_estimate).and_return(4)
      @burndown.baseline_data.should == [4, 3.5, 3, 2.5, 2, 1.5, 1, 0.5, 0]
    end
  end

  describe "actual data" do
    it "should return an array of burndown data points with the current estimate" do
      data_points = []
      data_points << mock_model(BurndownDataPoint, :story_points => 20)
      data_points << mock_model(BurndownDataPoint, :story_points => 10)
      data = [20, 10]
      BurndownDataPoint.should_receive(:for_iteration).with(@iteration).
        and_return(data_points)

      current_estimate = 7
      @iteration.stub!(:story_points_remaining).and_return(current_estimate)

      @burndown.actual_data.should == data << current_estimate
    end
  end

  describe "labels" do
    it "should return a hash with a key for each day of the iteration duration" do
      @iteration.should_receive(:duration).and_return(3)
      @burndown.labels.should == {
        1 => "1",
        2 => "2",
        3 => "3"
      }
    end
  end

  describe "to_png" do
    before :each do
      @gruff = mock(:gruff)
      Gruff::Line.stub!(:new).and_return(@gruff)
      @gruff.stub!(:data)
      @gruff.stub!(:to_blob)
      @gruff.stub!(:minimum_value=)
      @gruff.stub!(:y_axis_label=)
      @gruff.stub!(:x_axis_label=)
      @gruff.stub!(:labels=)
      @gruff.stub!(:theme=)

      @iteration.stub!(:story_points_remaining)
      
      @burndown.stub!(:baseline_data)
      @burndown.stub!(:actual_data)
      @burndown.stub!(:labels)
    end

    it "should create a new Gruff::Line object" do
      Gruff::Line.should_receive(:new)
      @burndown.to_png
    end

    it "should pass the width to gruff" do
      @burndown.width = "300"
      Gruff::Line.should_receive(:new).with(300)
      @burndown.to_png
    end

    it "should set the minimum value to 0" do
      @gruff.should_receive(:minimum_value=).with(0)
      @burndown.to_png
    end

    it "should set the y_axis_label text" do
      @gruff.should_receive(:y_axis_label=).with("Story Points")
      @burndown.to_png
    end

    it "should set the x_axis_label text" do
      @gruff.should_receive(:x_axis_label=).with("Day")
      @burndown.to_png
    end

    it "should set the x axis labels" do
      labels = {1 => 1, 2 => 2}
      @burndown.should_receive(:labels).and_return(labels)
      @gruff.should_receive(:labels=).with(labels)
      @burndown.to_png
    end

    it "should return the Gruff::Line blob" do
      blob = mock(:blob)
      @gruff.should_receive(:to_blob).and_return(blob)
      @burndown.to_png.should == blob
    end

    describe "plotting the baseline" do
      it "should use baseline_data" do
        @burndown.should_receive(:baseline_data)
        @burndown.to_png
      end

      it "should pass the baseline data to gruff" do
        data = []
        @burndown.stub!(:baseline_data).and_return(data)
        @gruff.should_receive(:data).with("Baseline", data)
        @burndown.to_png
      end
    end

    describe "plotting the story points" do
      it "should pass the story points with the current estimate to gruff" do
        data = []
        @burndown.should_receive(:actual_data).and_return(data)
        @gruff.should_receive(:data).with("Baseline", nil)
        @gruff.should_receive(:data).with("Actual", data)
        @burndown.to_png
      end
    end
  end

end
