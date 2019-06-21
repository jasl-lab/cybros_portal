class Company::DrillDownQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Company::Knowledge, :drill_down?
    @question_word = Current.jieba_keyword.extract(params[:question].to_s, 2)

    qw1 = @question_word.collect(&:first).first
    @qw1 = Company::Knowledge.user_synonym.fetch(qw1, qw1)
    qw2 = @question_word.collect(&:first).second
    @qw2 = Company::Knowledge.user_synonym.fetch(qw2, qw2)

    @direct_question = Company::DirectQuestion.find_by(question: params[:question])
    if @direct_question.present?
      @ans_1 = Company::Knowledge.find_by(question: @direct_question.real_question)
      return render
    end

    ans = if @qw2.present?
      Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{@qw1}%#{@qw2}%").or(Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{@qw2}%#{@qw1}%"))
    elsif @qw1.present?
      Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{@qw1}%")
    else
      Pundit.policy_scope(Current.user, Company::Knowledge).none
    end.limit(2)
    @ans_1 = ans.first || Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{@qw1}%").first
    @ans_2 = ans.second
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
