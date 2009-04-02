class AddLimitsToPaymentPlans < ActiveRecord::Migration
  def self.up
    add_column :payment_plans, :active_iteration_limit, :integer
    add_column :payment_plans, :project_limit, :integer
    add_column :payment_plans, :user_limit, :integer
  end

  def self.down
    remove_column :payment_plans, :user_limit
    remove_column :payment_plans, :project_limit
    remove_column :payment_plans, :active_iteration_limit
  end
end
