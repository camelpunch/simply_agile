class OrganisationMembersController < ApplicationController
  before_filter :get_organisation
  before_filter :new_user

  def create
    if @user.update_attributes(params[:user])
      redirect_to organisation_path
    else
      render :template => 'organisations/show'
    end
  end

  protected

  def new_user
    @user = User.new(:organisation => @organisation)
  end
end
