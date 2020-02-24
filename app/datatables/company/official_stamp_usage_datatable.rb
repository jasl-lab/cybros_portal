# frozen_string_literal: true

module Company
  class OfficialStampUsageDatatable < ApplicationDatatable
    def_delegator :@view, :company_official_stamp_usage_path
    def_delegator :@view, :view_attachment_company_official_stamp_usage_path
    def_delegator :@view, :start_approve_company_official_stamp_usage_path

    def initialize(params, opts = {})
      @official_stamp_usage_applies = opts[:official_stamp_usage_applies]
      super
    end

    def view_columns
      @view_columns ||= {
        employee_name: { source: 'Company::OfficialStampUsageApply.employee_name', cond: :like, searchable: true, orderable: true },
        clerk_code: { source: 'company::OfficialStampUsageApply.clerk_code', cond: :like, searchable: true, orderable: true },
        task_id: { source: 'company::OfficialStampUsageApply.begin_task_id', cond: :string_eq, searchable: true, orderable: true },
        belong_company_name: { source: 'company::OfficialStampUsageApply.belong_company_name', cond: :like, searchable: true, orderable: true },
        belong_department_name: { source: 'company::OfficialStampUsageApply.belong_department_name', cond: :like, searchable: true, orderable: true },
        stamp_to_place: { source: 'company::OfficialStampUsageApply.stamp_to_place', cond: :like, searchable: true, orderable: true },
        stamp_comment: { source: 'company::OfficialStampUsageApply.stamp_comment', cond: :like, searchable: true, orderable: true },
        status: { source: "company::OfficialStampUsageApply.status", cond: :string_eq, searchable: true, orderable: true },
        item_action: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        r_delete = link_to I18n.t('company.official_stamp_usages.index.actions.delete'), company_official_stamp_usage_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        r_start_approve = link_to I18n.t('company.official_stamp_usages.index.actions.start_approve'), start_approve_company_official_stamp_usage_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        see_attachment = if r.attachment.attached?
          link_to I18n.t('company.official_stamp_usages.new.attachment'), view_attachment_company_official_stamp_usage_path(r), remote: true
        end
        r_status = if r.status.present?
          "#{r.status} #{r.bpm_message}".html_safe
        end
        { employee_name: r.employee_name,
          clerk_code: r.clerk_code,
          task_id: (r.begin_task_id.present? ? link_to(I18n.t('company.copy_of_business_licenses.index.actions.look_workflow'), company_official_stamp_usage_path(id: r.id, begin_task_id: r.begin_task_id)) : ''),
          belong_company_name: r.belong_company_name,
          belong_department_name: r.belong_department_name,
          stamp_to_place: Company::OfficialStampUsageApply.sh_stamp_place.key(r.stamp_to_place),
          stamp_comment: "#{r.stamp_comment}#{see_attachment}".html_safe,
          status: r_status,
          item_action: "#{r_delete}#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @official_stamp_usage_applies
    end
  end
end
