class Company::DirectQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::DirectQuestion
    @direct_questions = Company::DirectQuestion.all
    @direct_question = Company::DirectQuestion.new
  end

  def create
    @direct_question = Company::DirectQuestion.new(direct_question_params)
    authorize @direct_question

    if @direct_question.save
      redirect_to company_direct_questions_path, notice: t('.success', question: @direct_question.question)
    else
      prepare_meta_tags title: t(".title")
      @direct_questions = Company::DirectQuestion.all
      render :index, notice: t('.failed')
    end
  end

  def destroy
    direct_question = Company::DirectQuestion.find(params[:id])
    authorize direct_question
    direct_question.destroy

    redirect_to company_direct_questions_path, notice: t('.success', question: direct_question.question)
  end

  protected

  def set_page_layout_data
    @_sidebar_name = 'company'
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.company.header"),
      link: company_root_path },
    { text: t("layouts.sidebar.company.direct_questions"),
      link: company_direct_questions_path }]
  end

  private

  def direct_question_params
    params[:company_direct_question].permit(:question, :real_question)
  end
end
