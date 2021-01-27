# frozen_string_literal: true

class Capital::FundDailyFillMissingsController < Capital::BaseController
  before_action :authenticate_user!
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @org_orders = Bi::OrgOrder.all.order(:org_order)
    @manual_cw_access_codes = ManualCwAccessCode.where(cw_rolename: 'CW_会计填报人')
    @th_cwtb_days = Ocdm::ThCwtbDay.order(reportdate: :desc)
      .where(filltype: 'write')
      .where.not(fillmancode: 'birobot01')
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
