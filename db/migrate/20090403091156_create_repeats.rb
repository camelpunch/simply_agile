class CreateRepeats < ActiveRecord::Migration
  def self.up
    create_table :repeats do |t|
      t.integer :payment_id
      t.integer :amount
      t.string :description
      t.text :authorization
      t.string :status
      t.string :status_detail

      t.timestamps
    end
  end

  def self.down
    drop_table :repeats
  end
end
