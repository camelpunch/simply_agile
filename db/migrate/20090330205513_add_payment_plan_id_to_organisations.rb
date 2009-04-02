class AddPaymentPlanIdToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :payment_plan_id, :integer
  end

  def self.down
    remove_column :organisations, :payment_plan_id
  end
end
