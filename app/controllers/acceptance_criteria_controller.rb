class AcceptanceCriteriaController < ApplicationController
  before_filter :get_project
  before_filter :get_story
  before_filter :new_acceptance_criterion, :only => :create
  before_filter :get_acceptance_criterion, :only => [:edit, :update]

  def create
    if @acceptance_criterion.update_attributes(params[:acceptance_criterion])
      render(:partial => 'acceptance_criteria/list')
    else
      render(:text => @acceptance_criterion.errors.full_messages.join("\n"),
             :status => :unprocessable_entity)
    end
  end

  def update
    story_status = @story.status

    if @acceptance_criterion.update_attributes(params[:acceptance_criterion])
      @story.reload
      if story_status != @story.status
        new_status = ActiveSupport::Inflector.titleize(@story.status)
        message = "Story status has changed to '#{new_status}'"
      end

      respond_to do |format|
        format.html do
          flash[:notice] = message
          redirect_to project_story_url(@story.project, @story)
        end

        format.js do
          render :text => message
        end
      end

    else
      render(:text => @acceptance_criterion.errors.full_messages.join("\n"),
             :status => :unprocessable_entity)
    end
  end

  def destroy
    @story.acceptance_criteria.destroy(params[:id])
    render :partial => 'acceptance_criteria/list'
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  protected

  def get_story
    @story = @project.stories.find(params[:story_id])
  end

  def get_acceptance_criterion
    @acceptance_criterion = @story.acceptance_criteria.find(params[:id])
  end

  def new_acceptance_criterion
    @acceptance_criterion = @story.acceptance_criteria.build
  end

end
