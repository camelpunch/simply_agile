class AddPaymentDatesToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :first_payment_date, :date
    add_column :organisations, :next_payment_date, :date
  end

  def self.down
    remove_column :organisations, :next_payment_date
    remove_column :organisations, :first_payment_date
  end
end
