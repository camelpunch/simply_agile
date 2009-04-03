describe "it uses protx", :shared => true do
  before :each do
    @vendor = "jandaweb" # This needs to match the protx.yml config file
    stub_payment_gateway
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

def stub_payment_gateway
    @gateway = mock(ActiveMerchant::Billing::ProtxGateway)
    ActiveMerchant::Billing::ProtxGateway.stub!(:new).and_return(@gateway)

    stub_authorize
    stub_capture
    stub_void
    stub_purchase
end

def stub_authorize
    @successful_authorization_response =
      YAML.load_file(fixtures_path_for(:successful_authorization))
    @gateway.stub!(:authorize).and_return(@successful_authorization_response)
end

def stub_capture
    @successful_capture_response =
      YAML.load_file(fixtures_path_for(:successful_capture))
    @gateway.stub!(:capture).and_return(@successful_capture_response)
end

def stub_void
    @successful_abort_response =
      YAML.load_file(fixtures_path_for(:successful_capture))
    @gateway.stub!(:void).and_return(@successful_abort_response)
end

def stub_purchase
    @successful_payment_response =
      YAML.load_file(fixtures_path_for(:successful_repeat))
    @gateway.stub!(:purchase).and_return(@successful_payment_response)
end

def fixtures_path_for(file)
    File.join(
      File.dirname(__FILE__), "fixtures", "protx",
      "#{file}.yml"
    )
end