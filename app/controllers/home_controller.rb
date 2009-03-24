class HomeController < ApplicationController
  before_filter :current_organisation
  before_filter :get_active_iterations

  def show
  end

  protected

  def get_active_iterations
    @active_iterations = @organisation.iterations.active
  end
end
