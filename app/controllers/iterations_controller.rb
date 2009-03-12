class IterationsController < ApplicationController
  before_filter :get_project
  before_filter :get_iteration, :only => [:edit, :show, :update]
  before_filter :new_iteration, :only => [:new, :create]
  before_filter :get_stories, :only => [:edit, :new]

  def create
    @iteration.save_with_planned_stories_attributes! params[:stories]

    flash[:notice] = "Iteration successfully created"
    redirect_to [@project, @iteration]

  rescue ActiveRecord::RecordInvalid => e
    @stories = e.record.planned_stories
    render :template => 'iterations/new'
  end

  def new
    if @stories.empty?
      render :template => 'iterations/new_guidance'
    end
  end

  def update
    @iteration.attributes = params[:iteration]
    @iteration.save_with_planned_stories_attributes! params[:stories]

    flash[:notice] = "Iteration successfully updated"
    redirect_to [@project, @iteration]

  rescue ActiveRecord::RecordInvalid => e
    @stories = e.record.planned_stories
    render :template => 'iterations/edit'
  end

  protected

  def get_iteration
    @iteration = @project.iterations.find(params[:id])
  end

  def get_stories
    @stories = @project.stories.assigned_or_available_for(@iteration)
  end

  def new_iteration
    @iteration = @project.iterations.build(params[:iteration])
  end

end
