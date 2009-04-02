module OrganisationSuspender
  GRACE_PERIOD = 7 # days

  def self.run
    Organisation.update_all("suspended = 't'",
                            ['next_payment_date < ?', Date.today - GRACE_PERIOD])
  end
end
