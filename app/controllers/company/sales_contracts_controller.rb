# frozen_string_literal: true

class Company::SalesContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def show
    authorize Bi::NewMapInfo, :allow_download?
    @sc = Bi::SaContract.find_by salescontractid: params[:id]
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
