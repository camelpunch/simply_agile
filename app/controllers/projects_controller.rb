class ProjectsController < ApplicationController
  before_filter :new_project, :only => [:new, :create]
  before_filter :get_project, :only => :show

  def create
    if @project.update_attributes(params[:project])
      flash[:notice] = "Project created."
      redirect_to @project
    else
      render :template => 'projects/new'
    end
  end

  protected

  def get_project
    @project = current_user.organisation.projects.find(params[:id])
  end

  def new_project
    @project = current_user.organisation.projects.build(params[:project])
  end
end
