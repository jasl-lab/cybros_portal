# frozen_string_literal: true

class CostSplit::HumanResourcesController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @all_company_names = Bi::OrgOrder.all_company_names
    @company_name = current_user.user_company_names.first
    @dept_options = Department.where(company_name: @company_name).pluck(:name, :dept_code)
    @depts = if params[:depts].present?
      params[:depts]
    else
      current_user.departments.collect(&:dept_code)
    end

    @users = User.includes(:departments).where(departments: { dept_code: @depts })
      .select(:id, :clerk_code, :chinese_name, :position_title, :company_code, :dept_code, :position_title)
  end

  def change_company
    company_name = params[:company_name]
    @dept_options = Department.where(company_name: company_name).pluck(:name, :dept_code)
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.cost_split.header'),
        link: cost_split_root_path },
      { text: t('layouts.sidebar.cost_split.human_resource'),
        link: cost_split_human_resources_path }]
    end
end
