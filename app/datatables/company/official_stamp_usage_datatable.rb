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
        attachments: { source: nil, searchable: false, orderable: false },
        created_at: { source: 'Company::OfficialStampUsageApply.created_at', searchable: false, orderable: true },
        task_id: { source: 'company::OfficialStampUsageApply.begin_task_id', cond: :string_eq, searchable: true, orderable: true },
        task_status: { source: 'company::OfficialStampUsageApply.status', searchable: false, orderable: true },
        belong_company_department: { source: 'company::OfficialStampUsageApply.belong_company_name', cond: :like, searchable: true, orderable: true },
        stamp_to_place: { source: 'company::OfficialStampUsageApply.stamp_to_place', cond: :like, searchable: true, orderable: true },
        application_class: { source: 'company::OfficialStampUsageApply.application_class', cond: :like, searchable: true, orderable: true },
        stamp_comment: { source: 'company::OfficialStampUsageApply.stamp_comment', cond: :like, searchable: true, orderable: true },
        item_action: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        task_id = r.begin_task_id.present? ? link_to(I18n.t('company.official_stamp_usages.index.actions.look_workflow'), company_official_stamp_usage_path(id: r.id, begin_task_id: r.begin_task_id)) : ''
        r_delete = if r.begin_task_id.blank?
          link_to I18n.t('company.official_stamp_usages.index.actions.delete'), company_official_stamp_usage_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        end
        r_start_approve = if r.begin_task_id.blank?
          link_to I18n.t('company.official_stamp_usages.index.actions.start_approve'), start_approve_company_official_stamp_usage_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        end
        see_attachments = r.attachments.collect do |attachment|
          link_to attachment.filename, view_attachment_company_official_stamp_usage_path(r, attachment_id: attachment.id), remote: true
        end
        task_status = if r.status.present?
          "#{r.status} #{r.bpm_message}".html_safe
        else
          "#{r.begin_task_id.present? ? '审批中' : nil}".html_safe
        end
        { employee_name: "#{r.employee_name}<br />#{r.clerk_code}".html_safe,
          attachments: see_attachments.join('<br />').html_safe,
          created_at: r.created_at,
          task_id: task_id,
          task_status: task_status,
          belong_company_department: "#{r.belong_company_name}<br />#{r.belong_department_name}".html_safe,
          stamp_to_place: Company::OfficialStampUsageApply.sh_stamp_place.key(r.stamp_to_place),
          application_class: r.application_class,
          stamp_comment: r.stamp_comment,
          item_action: "#{r_delete}<br />#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @official_stamp_usage_applies
    end
  end
end
