class InvoicesController < ApplicationController
  before_filter :get_invoice, :only => :show

  def index
    @invoices = @current_user.invoices
  end

  protected

  def get_invoice
    @invoice = @current_user.invoices.find params[:id]
  end

end
