# frozen_string_literal: true

class CostSplit::AllocationBasesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
  end

  def new
    @base_name = params[:base_name]
    @company_code = params[:company_code]
  end
end
