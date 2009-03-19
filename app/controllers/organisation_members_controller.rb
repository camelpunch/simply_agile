class OrganisationMembersController < ApplicationController
  before_filter :get_organisation
  before_filter :new_user, :only => [:create]
  before_filter :get_user, :only => [:destroy]

  def create
    if @user.update_attributes(params[:user])
      redirect_to organisation_path
    else
      render :template => 'organisations/show'
    end
  end

  def destroy
    @user.destroy
    redirect_to organisation_url
  end

  protected

  def new_user
    @user = User.new(
      :organisation => @organisation,
      :sponsor => @current_user
    )
  end

  def get_user
    @user = @organisation.users.find(params[:id])
  end
end
