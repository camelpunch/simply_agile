class Burndown
  attr_accessor :iteration
  attr_accessor :width

  DEFAULT_WIDTH = 600
  
  def initialize(iteration, options = {})
    self.iteration = iteration
    self.width = options[:width] || DEFAULT_WIDTH
  end

  def to_png
    gruff = Gruff::Line.new(width.to_i)

    gruff.theme = {
      :colors => %w(grey darkorange),
      :marker_color => 'black',
      :background_colors => 'white'
    }

    gruff.data("Baseline", baseline_data)
    gruff.data("Actual", actual_data)

    gruff.minimum_value = 0
    gruff.y_axis_label = "Story Points"
    gruff.x_axis_label = "Day"
    gruff.labels = labels

    gruff.to_blob
  end

  def baseline_data
    points = iteration.initial_estimate
    duration = iteration.duration - 1 # Don't need to work out the first day
    points_per_day = points.to_f / duration

    data = [points]
    (iteration.duration - 1).times do
      data << points -= points_per_day
    end
    data
  end

  def actual_data
    BurndownDataPoint.for_iteration(iteration).map(&:story_points) <<
      iteration.story_points_remaining
  end

  def labels
    labels = {}
    (1..iteration.duration).each { |v| labels[v] = v.to_s }
    labels
  end
end
