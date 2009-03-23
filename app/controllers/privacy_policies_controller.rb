class PrivacyPoliciesController < ApplicationController
  skip_before_filter :login_required
  layout "sessions"
end
