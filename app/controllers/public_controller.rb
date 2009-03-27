class PublicController < ApplicationController
  layout 'sessions'

  skip_before_filter :login_required
  skip_before_filter :select_organisation

  def show
    render :template => 'sessions/new'
  end
end
