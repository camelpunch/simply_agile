class StoriesController < ApplicationController
  before_filter :get_project
  before_filter :get_iteration, :only => [:new, :create]
  before_filter :get_story, :only => [:show, :estimate]
  before_filter :new_story, :only => [:new, :create]

  def backlog
    if @project.stories.backlog.empty?
      render :template => 'stories/backlog_guidance'
    end
  end

  def create
    if @story.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Story successfully created"
          redirect_to [@project, @story]
        end

        format.js do
          head :created, :location => project_story_url(@project, @story)
        end
      end

    elsif @story.iteration_id?
      @iteration = @story.iteration
      render(:status => :unprocessable_entity,
             :template => 'stories/new_with_iteration')
    else
      render(:status => :unprocessable_entity,
             :template => 'stories/new_with_project')
    end
  end

  def edit
    if params[:iteration_id]
      get_story_from_iteration
    else
      get_story

      if @story.iteration_id?
        redirect_to edit_project_iteration_story_url(@project, 
                                                     @story.iteration_id, 
                                                     @story)
      end
    end
  end

  def estimate
    render :partial => 'stories/estimate', :object => @story 
  end

  def new
    @story.content = <<STORY
As a 
I want 
So that 
STORY

    if @iteration
      render :template => 'stories/new_with_iteration'
    elsif @project
      render :template => 'stories/new_with_project'
    elsif current_user.organisation.projects.empty?
      render :template => 'stories/new_guidance'
    else
      render :template => 'stories/new_without_project'
    end
  end

  def update
    if params[:iteration_id]
      get_story_from_iteration
      
      @story.update_attributes! params[:story]

      respond_to do |format|
        format.html do
          if params[:story][:status]
            redirect_to project_iteration_url(@project, params[:iteration_id])
          else
            redirect_to project_iteration_story_url(@project,
                                                    params[:iteration_id],
                                                    @story)
          end
        end

        format.js do
          head :ok
        end
      end

    else
      get_story
      @story.update_attributes! params[:story]
      redirect_to [@project, @story]
    end

  rescue ActiveRecord::RecordInvalid => e
    render :template => 'stories/edit'
  end

  protected

  def get_iteration
    if params[:iteration_id] && @project
      @iteration = @project.iterations.find(params[:iteration_id])
    end
  end

  def get_story
    @story = @project.stories.find(params[:id])
  end

  def get_story_from_iteration
    @story = @project.stories.
      find(params[:id], 
           :conditions => ['iteration_id = ?', params[:iteration_id]])
  end

  def new_story
    if @iteration
      @story = @iteration.stories.build(params[:story])
    elsif @project
      @story = @project.stories.build(params[:story])
    else
      @story = Story.new
    end
  end

end
