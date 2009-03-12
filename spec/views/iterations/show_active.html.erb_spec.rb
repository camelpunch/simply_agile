require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/iterations/new" do
  before :each do
    @iteration = Iterations.active_iteration
    assigns[:iteration] = @iteration
    render 'iterations/show_active'
  end

  it_should_behave_like "a standard view"
end
