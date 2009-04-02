describe "it uses protx", :shared => true do
  before :each do
    @vendor = "jandaweb" # This needs to match the protx.yml config file
    @gateway = mock(ActiveMerchant::Billing::ProtxGateway)
    ActiveMerchant::Billing::ProtxGateway.stub!(:new).and_return(@gateway)

    response_path = File.join(
      File.dirname(__FILE__), "fixtures", "protx",
      'successful_authorization.yml'
    )
    @successful_authorization_response = YAML.load_file(response_path)
    @gateway.stub!(:authorize).and_return(@successful_authorization_response)
  end

  it "should set simlate to true" do
    ActiveMerchant::Billing::ProtxGateway.should_receive(:simulate=).with(true)
    do_protx_action
  end

  it "should create a new Protx gateway object" do
    ActiveMerchant::Billing::ProtxGateway.should_receive(:new).
      with(:login => @vendor)
    do_protx_action
  end
end