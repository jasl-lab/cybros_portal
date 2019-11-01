class Company::PendingQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::PendingQuestion
    @show_not_assigned_only = params[:show_not_assigned_only].present?
    @pending_questions = Pundit.policy_scope(Current.user, Company::PendingQuestion)
    @pending_questions = @pending_questions.where(owner_id: nil) if @show_not_assigned_only
  end

  def create
    pending_question = Company::PendingQuestion.find(params[:id])
    authorize pending_question

    redirect_to new_company_knowledge_maintain_path(q: pending_question.question, q_user_id: pending_question.user_id), notice: t('.success', question: pending_question.question)
  end

  def update
    pending_question = Company::PendingQuestion.find(params[:id])
    authorize pending_question
    owner_user = User.find params[:company_pending_question][:owner_id]
    if owner_user.present?
      openid = owner_user.email.split('@')[0]
      Wechat.api.custom_message_send Wechat::Message.to(openid).text("#{pending_question.user.chinese_name} 提出了一个小华无法回答的问题：\r\n#{pending_question.question}\r\n需要您的帮助。。。")
    end
    pending_question.update(owner: owner_user)

    redirect_to company_pending_questions_path(show_not_assigned_only: params[:show_not_assigned_only]),
      notice: t('.success', question: pending_question.question, user_name: pending_question.owner.chinese_name)
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
