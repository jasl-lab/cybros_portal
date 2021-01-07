# frozen_string_literal: true

class Company::ZhaofengMapsController < ApplicationController
  before_action :set_page_layout_data, if: -> { request.format.html? }


  def show
  end


  protected

    def set_page_layout_data
      @_sidebar_name = 'company'
    end
end
