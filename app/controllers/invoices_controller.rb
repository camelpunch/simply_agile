class InvoicesController < ApplicationController
  before_filter :get_invoice, :only => :show
  skip_before_filter :select_organisation

  def index
    @invoices = @current_user.invoices
  end

  protected

  def get_invoice
    @invoice = @current_user.invoices.find params[:id]
  end

end
