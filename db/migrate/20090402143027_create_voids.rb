class CreateVoids < ActiveRecord::Migration
  def self.up
    create_table :voids do |t|
      t.integer :payment_id
      t.string :status
      t.string :status_detail

      t.timestamps
    end
  end

  def self.down
    drop_table :voids
  end
end
