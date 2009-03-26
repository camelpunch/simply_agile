class BurndownsController < ApplicationController
  before_filter :get_iteration
  before_filter :get_burndown

  def show
    send_data(
      @burndown.to_png,
      :disposition => 'inline',
      :type => 'image/png',
      :filename => "#{@iteration.name} Burndown.png"
    )
  end

  protected

  def get_iteration
    @iteration =
      current_organisation.iterations.find(params[:iteration_id])
  end

  def get_burndown
    @burndown = @iteration.burndown(params[:width])
  end
end
