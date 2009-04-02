class CreateAuthorisations < ActiveRecord::Migration
  def self.up
    create_table :authorisations do |t|
      t.integer :payment_id
      t.string :vpstxid
      t.string :status
      t.string :status_detail
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :authorisations
  end
end
