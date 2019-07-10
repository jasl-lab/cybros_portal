class Company::KnowledgesController < ApplicationController
  wechat_api
  include BreadcrumbsHelper
  before_action :make_sure_wechat_user_login, only: %i[show index make_complaints]
  before_action :authenticate_user!, only: %i[modal make_complaints complain]
  before_action :set_knowledge, only: %i[modal show]
  before_action :set_page_layout_data, only: %i[index make_complaints], if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index make_complaints], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
  end

  def index
    knowledges = policy_scope(Company::Knowledge.all)
    authorize knowledges
    @category_1_list = Company::Knowledge.distinct.pluck(:category_1)
    params[:category_1] = case params[:category_1]
    when 'finance' then '财务'
    when 'human_resources' then '人力资源'
    when 'integrated_management' then '综合管理'
    when 'process_and_information' then '流程与信息化'
    when 'market_operation' then '市场运营'
    else params[:category_1]
    end
    knowledges = knowledges.where(category_1: params[:category_1]) if params[:category_1].present?
    knowledges = knowledges.where('question LIKE ?', "%#{params[:question]}%") if params[:question].present?
    @knowledges = knowledges.page(params[:page]).per(params[:per_page])
  end

  def modal
  end

  def make_complaints
    authorize Company::Knowledge
    add_to_breadcrumbs(t('.title'), make_complaints_company_home_knowledges_path)
  end

  def complain
    authorize Company::Knowledge
    redirect_to make_complaints_company_home_knowledges_path, notice: t('.success')
  end

  private

  def make_sure_wechat_user_login
    wechat_oauth2 do |user_name|
      Current.user = User.find_by email: "#{user_name}@thape.com.cn"
      if Current.user.present?
        sign_in Current.user
      else
        return redirect_to new_user_session_path
      end
    end unless current_user.present?
  end

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end

  def set_page_layout_data
    @_sidebar_name = "company"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.company.header"),
      link: company_root_path },
    { text: t("layouts.sidebar.company.knowledges"),
      link: company_home_knowledges_path }]
  end
end
