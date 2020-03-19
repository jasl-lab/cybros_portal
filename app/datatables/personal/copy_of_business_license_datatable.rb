# frozen_string_literal: true

module Personal
  class CopyOfBusinessLicenseDatatable < ApplicationDatatable
    def_delegator :@view, :person_copy_of_business_license_path
    def_delegator :@view, :view_attachment_person_copy_of_business_license_path
    def_delegator :@view, :start_approve_person_copy_of_business_license_path

    def initialize(params, opts = {})
      @copy_of_business_license_applies = opts[:copy_of_business_license_applies]
      super
    end

    def view_columns
      @view_columns ||= {
        employee_name: { source: 'Personal::CopyOfBusinessLicenseApply.employee_name', cond: :like, searchable: true, orderable: true },
        task_id_and_status: { source: 'Personal::CopyOfBusinessLicenseApply.begin_task_id', cond: :string_eq, searchable: true, orderable: true },
        belong_company_name: { source: 'Personal::CopyOfBusinessLicenseApply.belong_company_name', cond: :like, searchable: true, orderable: true },
        belong_department_name: { source: 'Personal::CopyOfBusinessLicenseApply.belong_department_name', cond: :like, searchable: true, orderable: true },
        contract_belong_company: { source: 'Personal::CopyOfBusinessLicenseApply.contract_belong_company', cond: :like, searchable: true, orderable: true },
        stamp_to_place: { source: 'Personal::CopyOfBusinessLicenseApply.stamp_to_place', cond: :like, searchable: true, orderable: true },
        stamp_comment: { source: 'Personal::CopyOfBusinessLicenseApply.stamp_comment', cond: :like, searchable: true, orderable: true },
        item_action: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        task_id = r.begin_task_id.present? ? link_to(I18n.t('person.copy_of_business_licenses.index.actions.look_workflow'), person_copy_of_business_license_path(id: r.id, begin_task_id: r.begin_task_id)) : ''
        r_delete = if r.begin_task_id.blank?
          link_to I18n.t('person.copy_of_business_licenses.index.actions.delete'), person_copy_of_business_license_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        end
        r_start_approve = if r.begin_task_id.blank?
          link_to I18n.t('person.copy_of_business_licenses.index.actions.start_approve'), start_approve_person_copy_of_business_license_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        end
        see_attachment = if r.attachments.attached?
          link_to I18n.t('person.copy_of_business_licenses.new.attachments'), view_attachment_person_copy_of_business_license_path(r), remote: true
        end
        task_id_and_status = if r.status.present?
          "#{task_id}<br />#{r.status} #{r.bpm_message}".html_safe
        else
          "#{task_id}<br />#{r.begin_task_id.present? ? '审批中' : nil}".html_safe
        end
        { employee_name: "#{r.employee_name}<br />#{r.clerk_code}".html_safe,
          task_id_and_status: task_id_and_status,
          belong_company_name: r.belong_company_name,
          belong_department_name: r.belong_department_name,
          contract_belong_company: r.contract_belong_company,
          stamp_to_place: Personal::CopyOfBusinessLicenseApply.sh_stamp_place.key(r.stamp_to_place),
          stamp_comment: "#{r.stamp_comment}<br />#{see_attachment}".html_safe,
          item_action: "#{r_delete}<br />#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @copy_of_business_license_applies
    end
  end
end
