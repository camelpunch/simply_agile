class OrganisationMembersController < ApplicationController
  before_filter :get_or_create_user, :only => [:create]
  before_filter :get_user, :only => [:destroy]

  def create
    unless @user.new_record? || @user.organisations.include?(current_organisation)
      current_organisation.organisation_members.create!(
        :user => @user,
        :sponsor => @current_user
      )
      redirect_to current_organisation
    else
      @organisation = current_organisation
      render :template => 'organisations/show'
    end
  end

  def destroy
    @user.organisation_members.
      find_by_organisation_id(current_organisation.id).destroy
    redirect_to organisation_url
  end

  protected

  def get_or_create_user
    @user = User.find(:first, :conditions => params[:user])
    @user ||= User.create(params[:user])
  end

  def get_user
    @user = current_organisation.users.find(params[:id])
  end
end
