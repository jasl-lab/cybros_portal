# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @using_lbs_qq = true
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
