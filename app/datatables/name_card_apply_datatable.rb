# frozen_string_literal: true

class NameCardApplyDatatable < ApplicationDatatable
  def_delegator :@view, :person_name_card_path
  def_delegator :@view, :start_approve_person_name_card_path

  def initialize(params, opts = {})
    @name_card_applies = opts[:name_card_applies]
    super
  end

  def view_columns
    @view_columns ||= {
      name: { source: "NameCardApply.chinese_name", cond: :like, searchable: true, orderable: true },
      english_name: { source: "NameCardApply.english_name", cond: :like, searchable: true, orderable: true },
      email: { source: "NameCardApply.email", cond: :like, searchable: true, orderable: true },
      task_id: { source: "NameCardApply.begin_task_id", cond: :string_eq, searchable: true, orderable: true },
      department_name: { source: "NameCardApply.department_name", cond: :like, searchable: true, orderable: true },
      en_department_name: { source: "NameCardApply.en_department_name", cond: :like, searchable: true, orderable: true },
      title: { source: "NameCardApply.title", cond: :like, searchable: true, orderable: true },
      en_title: { source: "NameCardApply.en_title", cond: :like, searchable: true, orderable: true },
      mobile: { source: "NameCardApply.mobile", cond: :like, searchable: true, orderable: true },
      phone_ext: { source: "NameCardApply.phone_ext", cond: :like, searchable: true, orderable: true },
      fax_no: { source: "NameCardApply.fax_no", cond: :like, searchable: true, orderable: true },
      print_out_box_number: { source: "NameCardApply.print_out_box_number", cond: :string_eq, searchable: true, orderable: true },
      status: { source: "NameCardApply.status", cond: :string_eq, searchable: true, orderable: true },
      item_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |r|
      r_delete = link_to I18n.t("person.name_cards.index.actions.delete"), person_name_card_path(r),
        method: :delete, data: { confirm: "你确定要删除吗？" }
      r_start_approve = link_to I18n.t("person.name_cards.index.actions.start_approve"), start_approve_person_name_card_path(r),
        class: "btn btn-primary", method: :patch, data: { disable_with: "处理中" }
      { name: r.chinese_name,
        english_name: r.english_name,
        email: r.email,
        task_id: (r.begin_task_id.present? ? link_to(I18n.t("person.name_cards.index.actions.look_workflow"), person_name_card_path(id: r.id, begin_task_id: r.begin_task_id)) : ""),
        department_name: r.department_name,
        en_department_name: r.en_department_name,
        title: r.title,
        en_title: r.en_title,
        mobile: r.mobile,
        phone_ext: r.phone_ext,
        fax_no: r.fax_no,
        print_out_box_number: r.print_out_box_number,
        status: r.status,
        item_action: "#{r_delete}#{r_start_approve}".html_safe
      }
    end
  end

  def get_raw_records
    @name_card_applies
  end
end
