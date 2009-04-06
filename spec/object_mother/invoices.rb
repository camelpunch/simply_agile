class Invoices < ObjectMother
  truncate_invoice
  def self.invoice_prototype
    {
      :amount => 23.23,
      :vat_amount => 0.35,
      :date => Date.today,
      :customer_name => 'Andrew',
      :customer_address_line_1 => 'Some Place',
      :customer_address_line_2 => 'Nice',
      :customer_county => 'Bananashire',
      :customer_town => 'Bananaton',
      :customer_postcode => 'BN1 1NA',
      :customer_country => 'Bananaland',
      :payment => Payments.create_payment!
    }
  end
end
