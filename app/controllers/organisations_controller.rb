class OrganisationsController < ApplicationController
  before_filter :get_organisation

  def show
  end

  protected

  def get_organisation
    @organisation = current_user.organisation
  end
end
