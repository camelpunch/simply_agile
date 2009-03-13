class StoriesController < ApplicationController
  before_filter :get_project
  before_filter :get_story, :only => [:show]
  before_filter :new_story, :only => [:new, :create]

  def create
    if @story.save
      flash[:notice] = "Story successfully created"
      redirect_to [@project, @story]
    else
      render :template => 'stories/new'
    end
  end

  def new
    @story.content = <<STORY
As a 
I want 
So that 
STORY
  end

  def update
    if params[:iteration_id]
      get_story_from_iteration
      @story.update_attributes! params[:story]
      respond_to do |format|
        format.html do
          redirect_to project_iteration_url(@project, params[:iteration_id])
        end

        format.js do
          head :ok
        end
      end
    end
  end

  protected

  def get_story
    @story = @project.stories.find(params[:id])
  end

  def get_story_from_iteration
    @story = @project.stories.
      find(params[:id], 
           :conditions => ['iteration_id = ?', params[:iteration_id]])
  end

  def new_story
    @story = @project.stories.build(params[:story])
  end

end
