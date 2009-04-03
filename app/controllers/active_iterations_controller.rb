class ActiveIterationsController < ApplicationController

  before_filter :get_iteration

  def create
    if @iteration.start
      redirect_to [@iteration.project, @iteration]
    else
      @project = @iteration.project
      render :template => 'iterations/show'
    end
  end

  protected

  def get_iteration
    @iteration =
      current_organisation.iterations.find(params[:iteration_id])
  end
end
