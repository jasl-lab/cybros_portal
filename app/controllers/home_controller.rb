# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
  end

  def logout
    sign_out(current_user) if current_user.present?
    redirect_to new_user_session_path, alert: "Logout success"
  end

  protected

  def set_page_layout_data
    prepare_meta_tags title: t("home.index.title")
    @_sidebar_name = "application"
  end
end
