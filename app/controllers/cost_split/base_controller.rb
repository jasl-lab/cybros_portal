# frozen_string_literal: true

class CostSplit::BaseController < ApplicationController
  before_action :authenticate_user!

  protected

    def set_page_layout_data
      @_sidebar_name = 'cost_split'
    end
end
