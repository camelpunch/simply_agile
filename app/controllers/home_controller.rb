class HomeController < ApplicationController
  before_filter :get_active_iterations

  def show
  end

  protected

  def get_active_iterations
    @active_iterations = current_organisation.iterations.active
  end
end
