class CaptureObserver < ActiveRecord::Observer
  def after_create(capture)
    return true unless capture.successful?

    organisation = capture.payment.organisation
    billing_address = organisation.payment_method.billing_address

    Invoice.create!(:payment => capture.payment,
                    :amount => capture.amount / 100.0,
                    :customer_name => billing_address.name,
                    :customer_address_line_1 => billing_address.address_line_1,
                    :customer_address_line_2 => billing_address.address_line_2,
                    :customer_county => billing_address.county,
                    :customer_town => billing_address.town,
                    :customer_postcode => billing_address.postcode,
                    :customer_country => billing_address.country)
  end
end
