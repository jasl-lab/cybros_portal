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
        clerk_code: { source: 'Personal::CopyOfBusinessLicenseApply.clerk_code', cond: :like, searchable: true, orderable: true },
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
        r_delete = link_to I18n.t('person.copy_of_business_licenses.index.actions.delete'), person_copy_of_business_license_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        r_start_approve = link_to I18n.t('person.copy_of_business_licenses.index.actions.start_approve'), start_approve_person_copy_of_business_license_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        see_attachment = if r.attachment.attached?
          link_to I18n.t('person.copy_of_business_licenses.new.attachment'), view_attachment_person_copy_of_business_license_path(r), remote: true
        end
        { employee_name: r.employee_name,
          clerk_code: r.clerk_code,
          belong_company_name: r.belong_company_name,
          belong_department_name: r.belong_department_name,
          contract_belong_company: r.contract_belong_company,
          stamp_to_place: Personal::CopyOfBusinessLicenseApply.sh_stamp_place.key(r.stamp_to_place),
          stamp_comment: "#{r.stamp_comment}#{see_attachment}".html_safe,
          item_action: "#{r_delete}#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @copy_of_business_license_applies
    end
  end
end
