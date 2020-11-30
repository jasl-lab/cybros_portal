# frozen_string_literal: true

class Report::GroupPredictContractsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::TrackContract, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    if @month_name.blank?
      flash[:alert] = I18n.t('not_data_authorized')
      raise Pundit::NotAuthorizedError
    end
    end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @last_available_date = policy_scope(Bi::TrackContract, :group_resolve).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
    @view_orgcode_sum = params[:view_orgcode_sum] == 'true'

    data = policy_scope(Bi::TrackContract, :group_resolve)
      .where(date: @last_available_date)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')

    data = if @view_orgcode_sum
      data.select('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode_sum orgcode, SUM(contractconvert) contractconvert, SUM(convertrealamount) convertrealamount')
        .group('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode_sum')
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = TRACK_CONTRACT.orgcode_sum')
        .order('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode_sum')
    else
      data.select('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode, SUM(contractconvert) contractconvert, SUM(convertrealamount) convertrealamount')
        .group('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode')
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = TRACK_CONTRACT.orgcode')
        .order('ORG_ORDER.org_order, TRACK_CONTRACT.orgcode')
    end

    @org_names = data.collect do |d|
      Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
    end
    @contract_convert = data.collect do |d|
      ((d.contractconvert || 0) / 10000.to_f).round(0)
    end
    @convert_real_amount = data.collect do |d|
      ((d.convertrealamount || 0) / 10000.to_f).round(0)
    end
    @contract_convert_totals = @contract_convert.zip(@convert_real_amount).map { |d| d[0] + d[1] }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_predict_contract'),
        link: report_group_predict_contract_path }]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
