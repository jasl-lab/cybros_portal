# frozen_string_literal: true

class Company::KnowledgesController < ApplicationController
  wechat_api
  before_action :authenticate_user!, only: :modal
  before_action :make_sure_wechat_user_login, only: %i[show index]
  before_action :set_knowledge, only: %i[modal show]
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
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
    @knowledges = knowledges.page(params[:page]).per(my_per_page)
  end

  def modal
  end

  private

    def set_knowledge
      @knowledge = Company::Knowledge.find(params[:id])
      authorize @knowledge
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.company.header'),
        link: company_root_path },
      { text: t('layouts.sidebar.company.knowledges'),
        link: company_home_knowledges_path }]
    end
end
