require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/projects/show" do

  before :each do
    @backlog = mock('Collection',
                    :all => [])
    @stories = mock('Collection',
                    :backlog => @backlog)
    @iterations = mock('Collection',
                       :empty? => true,
                       :active => [],
                       :pending => [])
    @project = mock_model(Project, 
                          :stories => @stories,
                          :iterations => @iterations,
                          :name => '',
                          :description => '')
    assigns[:project] = @project

    render 'projects/show'
  end

  it_should_behave_like "a standard view"
end
