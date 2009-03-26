class HomeController < ApplicationController
  before_filter :get_active_iterations
  before_filter :get_projects

  protected

  def get_active_iterations
    @active_iterations = current_organisation.iterations.active
  end

  def get_projects
    @projects = current_organisation.projects
  end
end
