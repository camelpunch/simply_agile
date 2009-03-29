class AcceptanceCriteriaController < ApplicationController
  before_filter :get_project
  before_filter :get_story
  before_filter :new_acceptance_criterion, :only => :create
  before_filter :get_acceptance_criterion, :only => [:edit, :update]
  before_filter :set_current_user_on_resource

  def create
    respond_to do |format|
      format.html do
        if @acceptance_criterion.update_attributes(params[:acceptance_criterion])
          redirect_to [@project, @story.iteration, @story]
        else
          render(:template => 'stories/show')
        end
      end

      format.js do
        if @acceptance_criterion.update_attributes(params[:acceptance_criterion])
          render(:partial => 'acceptance_criteria/list')
        else
          render(:text => @acceptance_criterion.errors.full_messages.join("\n"),
                 :status => :unprocessable_entity)
        end
      end
    end
  end

  def update
    previous_story_status = @story.status
    previous_story_users_empty = @story.users.empty?

    if @acceptance_criterion.update_attributes(params[:acceptance_criterion])
      @story.reload
      if previous_story_status != @story.status
        new_status = ActiveSupport::Inflector.titleize(@story.status)
        message = "Story status has changed to '#{new_status}'. "
      end

      if !previous_story_users_empty && @story.users.empty?
        message ||= ''
        message << "Story team members have been removed." 
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
    @story.acceptance_criteria.find(params[:id]).destroy
    respond_to do |format|
      format.html do
        redirect_to [@project, @story.iteration, @story]
      end

      format.js do
        render :partial => 'acceptance_criteria/list'
      end
    end
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
