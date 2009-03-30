class HomeController < ApplicationController
  before_filter :get_active_iterations
  before_filter :get_projects
  before_filter :get_active_iterations_worked_on
  before_filter :get_recently_finished_iterations_worked_on
  before_filter :get_stories

  def show
    if @active_iterations_worked_on.empty? &&
        @recently_finished_iterations_worked_on.empty?
      render :template => 'home/show_without_work'
    end
  end

  protected

  def get_stories
    @stories = current_user.active_stories_worked_on(current_organisation)
  end

  def get_active_iterations_worked_on
    @active_iterations_worked_on = 
      current_user.active_iterations_worked_on(current_organisation)
  end

  def get_recently_finished_iterations_worked_on
    @recently_finished_iterations_worked_on =
      current_user.recently_finished_iterations_worked_on(current_organisation)
  end

  def get_active_iterations
    @active_iterations = current_organisation.iterations.active
  end

  def get_projects
    @projects = current_organisation.projects
  end
end
