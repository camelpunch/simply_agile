class ActiveIterationsController < ApplicationController

  before_filter :get_iteration

  def create
    @iteration.start
    redirect_to [@iteration.project, @iteration]
  end

  protected

  def get_iteration
    @iteration =
      current_user.organisation.iterations.find(params[:iteration_id])
  end
end
