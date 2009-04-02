class CreateCaptures < ActiveRecord::Migration
  def self.up
    create_table :captures do |t|
      t.integer :payment_id
      t.string :status
      t.string :status_detail
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :captures
  end
end
