class OrganisationsController < ApplicationController
  before_filter :get_organisation
  before_filter :new_user

  protected

  def new_user
    @user = User.new
  end
end
