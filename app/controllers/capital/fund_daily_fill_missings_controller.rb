# frozen_string_literal: true

class Capital::FundDailyFillMissingsController < Capital::BaseController
  before_action :authenticate_user!
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Ocdm::ThCwtbDay).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @org_orders = Bi::OrgOrder.all.order(:org_order)
    @manual_cw_access_codes = ManualCwAccessCode.where(cw_rolename: 'CW_会计填报人')
    @th_cwtb_days = Ocdm::ThCwtbDay.order(reportdate: :desc)
      .where(reportdate: beginning_of_month..beginning_of_month.end_of_month)
      .where(filltype: 'write')
      .where.not(fillmancode: 'birobot01')
  end

  def create
    @user = User.find params[:user_id]
    Wechat.api(:bi).message_send(@user.wecom_id_with_fallback, "您好，本月您已累计三次未填写每日资金日报，需尽快填写，#{capital_fund_daily_fill_missing_url}")
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.capital_report.header'),
        link: report_capital_report_path }]
    end
end
