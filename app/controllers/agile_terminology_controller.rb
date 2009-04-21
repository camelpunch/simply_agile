class AgileTerminologyController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation

  layout 'landing'

  def project
  end

  def organisation
  end

  def user_story
  end

  def iteration
  end

end
