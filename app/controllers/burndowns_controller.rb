class BurndownsController < ApplicationController
  before_filter :get_burndown

  def show
  end

  protected

  def get_burndown
    @burndown = @iteration.burndown
  end
end
