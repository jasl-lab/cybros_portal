# frozen_string_literal: true

class CostSplit::CostAllocationSummariesController < CostSplit::BaseController
  def show
    prepare_meta_tags title: t('.title')
  end
end
