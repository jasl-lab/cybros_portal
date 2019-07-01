class Company::PendingQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::PendingQuestion
    @pending_questions = Company::PendingQuestion.all
  end

  def create
    pending_question = Company::PendingQuestion.find(params[:id])
    authorize pending_question
    pending_question.destroy

    redirect_to new_company_knowledge_maintain_path(q: pending_question.question, q_user_id: pending_question.user_id), notice: t('.success', question: pending_question.question)
  end

  def destroy
    pending_question = Company::PendingQuestion.find(params[:id])
    authorize pending_question
    pending_question.destroy

    redirect_to company_pending_questions_path, notice: t('.success', question: pending_question.question)
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
    { text: t("layouts.sidebar.company.pending_questions"),
      link: company_pending_questions_path }]
  end
end
