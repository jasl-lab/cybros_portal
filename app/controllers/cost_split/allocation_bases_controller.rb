# frozen_string_literal: true

class CostSplit::AllocationBasesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
  end
end
