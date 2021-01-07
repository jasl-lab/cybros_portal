# frozen_string_literal: true

class OperationEntry::HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'operation_entry'
    end
end
