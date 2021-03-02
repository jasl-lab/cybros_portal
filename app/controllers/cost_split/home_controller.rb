# frozen_string_literal: true

class CostSplit::HomeController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
  end
end
