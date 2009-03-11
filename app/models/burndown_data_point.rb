class BurndownDataPoint < ActiveRecord::Base
  belongs_to :iteration

  named_scope :for_iteration, lambda { |iteration|
    {
      :conditions => { :iteration_id => iteration.id },
      :order => 'date '
    }
  }
end
