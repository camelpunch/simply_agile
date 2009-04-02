module PaymentGateway
  def gateway
    ActiveMerchant::Billing::ProtxGateway.simulate = true if config['simulate']
    @gateway ||= ActiveMerchant::Billing::ProtxGateway.new(:login => vendor)
  end

  def vendor
    @vendor ||= config['vendor']
  end

  protected

  def config
    @config ||= YAML.load_file(config_file)[RAILS_ENV]
  end

  def config_file
    File.expand_path(File.join(RAILS_ROOT, 'config', 'protx.yml'))
  end
end