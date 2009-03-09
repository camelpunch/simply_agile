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

  protected

  def get_story
    @story = @project.stories.find(params[:id])
  end

  def new_story
    @story = @project.stories.build(params[:story])
  end

end
