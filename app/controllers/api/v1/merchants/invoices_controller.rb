class Api::V1::Merchants::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices
  
    invoices = invoices.where(status: params[:status]) if params[:status].present?
  
    #  Only apply the coupon filter when explicitly requested as true
    invoices = invoices.where.not(coupon_id: nil) if params[:only_with_coupons] == "true"
  
    render json: InvoiceSerializer.new(invoices)
  end

  def create 
    merchant = Merchant.find(params[:merchant_id])
    invoice = merchant.invoices.new(invoice_params)

    if invoice.save
      invoice.coupon.increment_usage! if invoice.coupon.present? 
      render json: InvoiceSerializer.new(invoice), status: :created
    else
      render json: {errors: invoice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:customer_id, :status, :coupon_id)
  end
end