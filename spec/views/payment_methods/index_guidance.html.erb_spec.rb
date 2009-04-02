require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/payment_methods/index_guidance" do
  before(:each) do
    assigns[:current_user] = mock_model User
    assigns[:payment_methods] = []
    render 'payment_methods/index_guidance'
  end

  it_should_behave_like "guidance"
end
