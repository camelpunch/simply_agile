class PublicController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :select_organisation
end
