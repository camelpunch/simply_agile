class RepeatObserver < ActiveRecord::Observer
  def after_create(repeat)
    return true unless repeat.successful?

    organisation = repeat.payment.organisation
    payment_method = organisation.payment_method
    payment_plan = organisation.payment_plan
    billing_address = organisation.payment_method.billing_address

    Invoice.create!(:user => payment_method.user,
                    :payment => repeat.payment,
                    :date => organisation.next_payment_date,
                    :organisation_name => organisation.name,
                    :payment_plan_name => payment_plan.name,
                    :payment_plan_price => payment_plan.price,
                    :amount => payment_plan.price,
                    :customer_name => billing_address.name,
                    :customer_address_line_1 => billing_address.address_line_1,
                    :customer_address_line_2 => billing_address.address_line_2,
                    :customer_county => billing_address.county,
                    :customer_town => billing_address.town,
                    :customer_postcode => billing_address.postcode,
                    :customer_country => billing_address.country)
  end
end
