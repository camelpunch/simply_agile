class ProjectsController < ApplicationController
  before_filter :new_project, :only => [:new, :create]
  before_filter :get_project, :only => [:show, :edit, :update]

  def create
    if @project.update_attributes(params[:project])
      flash[:notice] = "Project created."
      redirect_to @project
    else
      render :template => 'projects/new'
    end
  end

  def update
    if @project.update_attributes(params[:project])
      respond_to do |format|
        format.html do
          flash[:notice] = "Project updated."
          redirect_to @project
        end

        format.js do
          head :ok
        end
      end
    else
      render :template => 'projects/edit'
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
