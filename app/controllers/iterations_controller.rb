class IterationsController < ApplicationController
  before_filter :get_project
  before_filter :get_iteration, :only => [:show]
  before_filter :new_iteration, :only => [:new, :create]

  def create
    Iteration.transaction do
      @project.stories.each_with_index do |story, idx|
        story_params = params[:stories][story.id.to_s]
        @project.stories[idx].estimate = story_params[:estimate]
        story_should_be_assigned = story_params[:include].to_i == 1

        if story_should_be_assigned
          @iteration.stories << story 
        else
          @project.stories[idx].save!
        end
      end

      @iteration.save!
      flash[:notice] = "Iteration successfully created"
      redirect_to [@project, @iteration]
    end

  rescue ActiveRecord::RecordInvalid
    render :template => 'iterations/new'
  end

  def new
    if @project.stories.empty?
      flash[:notice] = "This project has no stories. Make a story here before
      planning an iteration."
      redirect_to new_project_story_url(@project)
    end
  end

  def show
    if @iteration.active?
      render :template => 'iterations/show_active'
    end
  end

  protected

  def get_iteration
    @iteration = @project.iterations.find(params[:id])
  end

  def new_iteration
    @iteration = @project.iterations.build(params[:iteration])
  end

end
