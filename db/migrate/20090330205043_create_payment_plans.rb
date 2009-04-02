class CreatePaymentPlans < ActiveRecord::Migration
  def self.up
    create_table :payment_plans do |t|
      t.string :name
      t.text :description
      t.decimal :price

      t.timestamps
    end
  end

  def self.down
    drop_table :payment_plans
  end
end
