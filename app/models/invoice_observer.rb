class InvoiceObserver < ActiveRecord::Observer
  def before_validation_on_create(invoice)
    return true unless invoice.amount?
    invoice.vat_rate = Invoice::VAT_RATE
    invoice.vat_amount = (invoice.amount * Invoice::VAT_RATE) / 100.0
  end

  def after_create(invoice)
    UserMailer.deliver_invoice(invoice)
  end
end
