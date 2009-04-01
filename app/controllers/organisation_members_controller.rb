class OrganisationMembersController < ApplicationController
  before_filter :get_organisation
  before_filter :new_organisation_member, :only => [:index, :create]

  def create
    if @organisation_member.save
      redirect_to [@organisation, :members]
    else
      @organisation = current_organisation
      render :template => 'organisation_members/index'
    end
  end

  def destroy
    @organisation.members.find(params[:id]).destroy
    redirect_to [@organisation, :members]
  end

  protected

  def get_organisation
    @organisation = current_user.organisations.find(params[:organisation_id])
  end

  def new_organisation_member
    email_address = 
      if params[:organisation_member]
        then params[:organisation_member].delete(:email_address)
      else ''
      end

    @user = User.find_or_create_by_email_address email_address
    @organisation_member = OrganisationMember.new(:organisation => @organisation,
                                                  :user => @user,
                                                  :sponsor => current_user)
  end
end
