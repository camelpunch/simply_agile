class Iteration < ActiveRecord::Base
  # for use after failed save_with_planned_stories_attributes!
  attr_accessor :planned_stories

  attr_protected :project_id
  belongs_to :project
  has_many :stories
  validates_presence_of :name, :duration, :project_id

  def validate
    errors.add(:stories, "must be assigned") if stories.empty?
  end

  def save_with_planned_stories_attributes!(attributes)
    Iteration.transaction do
      stories.clear # no dependent => :destroy or :delete_all

      self.planned_stories = project.stories.find(attributes.keys)

      planned_stories.each do |story|
        story_attributes = attributes[story.id.to_s]
        included = story_attributes.delete('include') == '1'

        if included
          story.attributes = story_attributes
          self.stories << story
        else
          story.update_attributes!(story_attributes)
        end
      end

      save!
    end
  end

  def name
    if attributes["name"]
      attributes["name"]
    elsif project
      "Iteration #{project.iterations.count + 1}"
    end
  end

  def to_s
    name || 'New Iteration'
  end

  def story_points_remaining
    stories.incomplete.inject(0) do |sum, st|
      sum + st.estimate.to_i
    end
  end

  def start
    unless active?
      self.update_attributes(
        :start_date => Date.today,
        :initial_estimate => story_points_remaining
      )
    end
  end

  def end_date
    start_date + duration
  end

  def days_remaining
    end_date - Date.today
  end

  def active?
    ! self.start_date.nil?
  end

  def burndown
    Burndown.new(self)
  end
end
