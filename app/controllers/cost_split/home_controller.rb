# frozen_string_literal: true

class CostSplit::HomeController < CostSplit::BaseController
  def show
    prepare_meta_tags title: t('.title')
  end
end
