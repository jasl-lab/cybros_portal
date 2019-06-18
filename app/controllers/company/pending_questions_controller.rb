class Company::PendingQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::PendingQuestion
    @knowledges = Company::PendingQuestion.all
  end

  def create
    @pending_question = Company::PendingQuestion.new(knowledge_params)
    authorize @pending_question

    if @pending_question.save
      redirect_to company_knowledge_maintains_path, notice: t('.success')
    else
      render :new
    end
  end

  def destroy
    @pending_question = Company::PendingQuestion.find(params[:id])
    authorize @pending_question
    @pending_question.destroy
    redirect_to company_pending_questions_path, notice: t('.success')
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
