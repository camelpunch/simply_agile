class IterationsController < ApplicationController
  before_filter :get_project
  before_filter :get_iteration, :only => [:edit, :show, :update]
  before_filter :new_iteration, :only => [:new, :create]

  def create
    process_iteration_and_stories!

    flash[:notice] = "Iteration successfully created"
    redirect_to [@project, @iteration]

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

  def update
    process_iteration_and_stories!

    flash[:notice] = "Iteration successfully updated"
    redirect_to [@project, @iteration]

  rescue ActiveRecord::RecordInvalid
    render :template => 'iterations/edit'
  end

  protected

  def get_iteration
    @iteration = @project.iterations.find(params[:id])
  end

  def new_iteration
    @iteration = @project.iterations.build(params[:iteration])
  end

  def process_iteration_and_stories!
    Iteration.transaction do
      @project.stories.each_with_index do |story, idx|
        story_params = params[:stories][story.id.to_s]

        @project.stories[idx].estimate = story_params[:estimate]

        assignment_requested = story_params[:include].to_i == 1
        already_assigned = @iteration.stories.include?(story)

        if assignment_requested && !already_assigned
          @iteration.stories << story
        elsif !assignment_requested && already_assigned
          @iteration.stories.delete(story)
        end

        if !assignment_requested
          @project.stories[idx].save! # saves estimate
        end
      end

      @iteration.save!
    end
  end

end
