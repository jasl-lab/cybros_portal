# frozen_string_literal: true

class CostSplit::SetBaselineJobTypesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
  end
end
