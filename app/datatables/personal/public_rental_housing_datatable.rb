# frozen_string_literal: true

module Personal
  class PublicRentalHousingDatatable < ApplicationDatatable
    def_delegator :@view, :person_public_rental_housing_path
    def_delegator :@view, :view_attachment_person_public_rental_housing_path
    def_delegator :@view, :start_approve_person_public_rental_housing_path

    def initialize(params, opts = {})
      @public_rental_housing_applies = opts[:public_rental_housing_applies]
      super
    end

    def view_columns
      @view_columns ||= {
        employee_name: { source: 'Personal::PublicRentalHousingApply.employee_name', cond: :like, searchable: true, orderable: true },
        attachments: { source: nil, searchable: false, orderable: false },
        created_at: { source: 'Personal::PublicRentalHousingApply.created_at', searchable: false, orderable: true },
        task_id: { source: 'Personal::PublicRentalHousingApply.begin_task_id', cond: :string_eq, searchable: true, orderable: true },
        task_status: { source: 'Personal::PublicRentalHousingApply.status', searchable: false, orderable: true },
        belong_company_department: { source: 'Personal::PublicRentalHousingApply.belong_company_name', cond: :like, searchable: true, orderable: true },
        stamp_to_place: { source: 'Personal::PublicRentalHousingApply.stamp_to_place', cond: :like, searchable: true, orderable: true },
        stamp_comment: { source: 'Personal::PublicRentalHousingApply.stamp_comment', cond: :like, searchable: true, orderable: true },
        status: { source: "Personal::PublicRentalHousingApply.status", cond: :string_eq, searchable: true, orderable: true },
        item_action: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        task_id = r.begin_task_id.present? ? link_to(I18n.t('person.public_rental_housings.index.actions.look_workflow'), person_public_rental_housing_path(id: r.id, begin_task_id: r.begin_task_id)) : ''
        r_delete = if r.begin_task_id.blank?
          link_to I18n.t('person.public_rental_housings.index.actions.delete'), person_public_rental_housing_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        end
        r_start_approve = if r.begin_task_id.blank?
          link_to I18n.t('person.public_rental_housings.index.actions.start_approve'), start_approve_person_public_rental_housing_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        end
        see_attachments = r.attachments.collect do |attachment|
          link_to attachment.filename, view_attachment_person_public_rental_housing_path(r, attachment_id: attachment.id), remote: true
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
          stamp_to_place: Personal::PublicRentalHousingApply.sh_stamp_place.key(r.stamp_to_place),
          stamp_comment: r.stamp_comment,
          item_action: "#{r_delete}<br />#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @public_rental_housing_applies
    end
  end
end
