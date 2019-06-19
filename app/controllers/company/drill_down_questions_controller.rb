class Company::DrillDownQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Company::Knowledge, :drill_down?
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "company"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.company.header"),
      link: company_root_path },
    { text: t("layouts.sidebar.company.drill_down_question"),
      link: company_drill_down_question_path }]
  end
end
