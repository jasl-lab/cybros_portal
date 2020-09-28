# frozen_string_literal: true

class CostSplit::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  private

    def set_page_layout_data
      @_sidebar_name = 'cost_split'
    end
end
