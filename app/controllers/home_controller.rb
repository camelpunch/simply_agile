class HomeController < ApplicationController
  before_filter :get_organisation
  before_filter :get_active_iterations

  def show
  end

  protected

  def get_organisation
    @organisation = current_user.organisation
  end

  def get_active_iterations
    @active_iterations = @organisation.iterations.active
  end
end
