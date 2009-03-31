class OrganisationMembersController < ApplicationController
  before_filter :new_organisation_member, :only => [:index, :create]
  before_filter :get_user, :only => [:destroy]

  def index
    @organisation = current_organisation
  end

  def create
    if @organisation_member.save
      redirect_to [current_organisation, :members]
    else
      @organisation = current_organisation
      render :template => 'organisation_members/index'
    end
  end

  def destroy
    @user.organisation_members.
      find_by_organisation_id(current_organisation.id).destroy
    redirect_to [current_organisation, :members]
  end

  protected

  def new_organisation_member
    email_address = 
      if params[:organisation_member]
        then params[:organisation_member].delete(:email_address)
      else ''
      end

    @user = User.find_or_create_by_email_address email_address
    @organisation_member = OrganisationMember.new(:organisation => current_organisation,
                                                  :user => @user,
                                                  :sponsor => current_user)
  end

  def get_user
    @user = current_organisation.users.find(params[:id])
  end
end
