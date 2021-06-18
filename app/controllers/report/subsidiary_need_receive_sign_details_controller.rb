# frozen_string_literal: true

class Report::SubsidiaryNeedReceiveSignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::SubCompanyNeedReceiveSignDetail
    prepare_meta_tags title: t('.title')

    @all_month_names = policy_scope(Bi::SubCompanyNeedReceiveSignDetail).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    if @month_name.blank?
      flash[:alert] = I18n.t('not_data_authorized')
      raise Pundit::NotAuthorizedError
    end
    @end_of_date = policy_scope(Bi::SubCompanyNeedReceiveSignDetail)
      .where(date: Date.parse(@month_name).beginning_of_month..Date.parse(@month_name).end_of_month).order(date: :desc).pluck(:date).first
    all_org_long_names = policy_scope(Bi::SubCompanyNeedReceiveSignDetail).all_org_long_names(@end_of_date)
    all_org_short_names = all_org_long_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @all_org_names = all_org_short_names.zip(all_org_long_names)
    @org_name = params[:org_name]&.strip
    @dept_codes_options = Bi::OrgReportDeptOrder.where("组织": @org_name).order(:"部门排名").pluck(:"部门", :"编号")
    @dept_codes = params[:dept_codes]
    @total_sign_receive_great_than = params[:total_sign_receive_great_than]
    @over_amount_great_than = params[:over_amount_great_than]
    @accneedreceive_gt3_months_great_than = params[:accneedreceive_gt3_months_great_than]
    @can_hide_item = pundit_user.roles.pluck(:report_reviewer).any?
    @show_hide_item = params[:show_hide_item] == 'true' && @can_hide_item

    respond_to do |format|
      format.html
      format.json do
        subsidiary_need_receive_sign_details = policy_scope(Bi::SubCompanyNeedReceiveSignDetail)
        render json: SubsidiaryNeedReceiveSignDetailDatatable.new(params,
          subsidiary_need_receive_sign_details: subsidiary_need_receive_sign_details,
          end_of_date: @end_of_date,
          org_name: @org_name,
          dept_codes: @dept_codes,
          total_sign_receive_great_than: @total_sign_receive_great_than.to_i * 10000,
          over_amount_great_than: @over_amount_great_than.to_i * 10000,
          accneedreceive_gt3_months_great_than: @accneedreceive_gt3_months_great_than.to_i * 10000,
          can_hide_item: @can_hide_item,
          show_hide: @show_hide_item,
          view_context: view_context)
      end
    end
  end

  def hide
    authorize Bi::SubCompanyNeedReceiveSignDetail
    sales_contract_code = params[:sales_contract_code]
    Bi::SubCompanyNeedReceiveSignDetail.where(salescontractcode: sales_contract_code).update_all(need_hide: true)
    redirect_to report_subsidiary_need_receive_sign_detail_path
  end

  def un_hide
    authorize Bi::SubCompanyNeedReceiveSignDetail
    sales_contract_code = params[:sales_contract_code]
    Bi::SubCompanyNeedReceiveSignDetail.where(salescontractcode: sales_contract_code).update_all(need_hide: nil)
    redirect_to report_subsidiary_need_receive_sign_detail_path(show_hide_item: true)
  end

  def org_name_change
    org_name = params[:org_name]
    @dept_codes = Bi::OrgReportDeptOrder.where("组织": org_name).order(:"部门排名").pluck(:"部门", :"编号")
  end

  def total_receivables_drill_down
    contractcode = params[:contractcode]
    end_of_date = params[:end_of_date]
    @details = Bi::SubCompanyNeedReceiveSignOrigin.where(合同编号: contractcode, date: end_of_date)
  end

  def financial_receivables_drill_down
    contractcode = params[:contractcode]
    end_of_date = params[:end_of_date]
    @details = Bi::SubCompanyNeedReceiveAccountDetail
      .where('need_receive > 0')
      .where(contractcode: contractcode, date: end_of_date)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.subsidiary_need_receive_sign_detail'),
        link: report_subsidiary_need_receive_sign_detail_path }]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
