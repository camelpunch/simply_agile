class Iteration < ActiveRecord::Base
  attr_protected :project_id
  belongs_to :project
  has_many :stories
  validates_presence_of :name, :duration, :project_id

  def validate
    errors.add(:stories, "must be assigned") if stories.empty?
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
end
