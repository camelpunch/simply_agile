class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :payment_id
      t.decimal :amount, :precision => 5, :scale => 2
      t.decimal :vat_rate
      t.decimal :vat_amount, :precision => 5, :scale => 2
      t.string :customer_name
      t.string :customer_address_line_1
      t.string :customer_address_line_2
      t.string :customer_county
      t.string :customer_town
      t.string :customer_postcode
      t.string :customer_country

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
