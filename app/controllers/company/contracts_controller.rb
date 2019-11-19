# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @hide_app_footer = true

    @all_cities = Bi::NewMapInfo.all_cities
    @city = '上海市'

    @all_tracestates = Bi::NewMapInfo.all_tracestates
    @tracestate = '跟踪中'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
