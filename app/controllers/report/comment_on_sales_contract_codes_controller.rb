# frozen_string_literal: true

class Report::CommentOnSalesContractCodesController < ApplicationController
  def create
    coc_params = comment_on_sales_contract_code_params
    @coc = Bi::CommentOnSalesContractCode.find_or_initialize_by(sales_contract_code: coc_params[:sales_contract_code], record_month: coc_params[:record_month])
    @coc.update(coc_params)
  end

  private

    def comment_on_sales_contract_code_params
      params[:bi_comment_on_sales_contract_code].permit(:sales_contract_code, :record_month, :comment)
    end
end
