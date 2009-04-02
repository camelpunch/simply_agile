class OrganisationObserver < ActiveRecord::Observer

  def before_create(organisation)
    today = Date.today

    organisation.next_payment_date = 
      if today.day > 28
        then Date.new(today.year, today.month + 2, 1)
      else Date.new(today.year, today.month + 1, today.day)
      end
  end

end
