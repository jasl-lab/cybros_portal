# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
  end

  protected

  def set_page_layout_data
    prepare_meta_tags title: t("home.show.title")
    @_sidebar_name = "application"
  end
end
