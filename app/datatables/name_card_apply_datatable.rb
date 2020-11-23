# frozen_string_literal: true

class NameCardApplyDatatable < ApplicationDatatable
  def_delegator :@view, :image_tag
  def_delegator :@view, :person_name_card_path
  def_delegator :@view, :edit_person_name_card_path
  def_delegator :@view, :start_approve_person_name_card_path
  def_delegator :@view, :download_name_card_person_name_cards_path

  def initialize(params, opts = {})
    @name_card_applies = opts[:name_card_applies]
    @only_see_approved = opts[:only_see_approved]
    @current_user = opts[:current_user]
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
      r_chinese_name = if Pundit.policy!(@current_user, r).upload?
        if r.printed_name_card.attached?
          "#{r.chinese_name}<br />#{link_to(I18n.t("person.name_cards.index.actions.upload"), edit_person_name_card_path(id: r.id), remote: true)}
          <br />#{image_tag r.printed_name_card, width: '100px' }".html_safe
        else
          "#{r.chinese_name}<br />#{link_to(I18n.t("person.name_cards.index.actions.upload"), edit_person_name_card_path(id: r.id), remote: true)}".html_safe
        end
      else
        if (r.user.id == @current_user.id || r.email == @current_user.email) && r.printed_name_card.attached?
          "#{r.chinese_name}<br />#{link_to(I18n.t("person.name_cards.index.actions.download"), download_name_card_person_name_cards_path(clerk_code: r.user.clerk_code, name_card_apply_id: r.id))}".html_safe
        else
          r.chinese_name
        end
      end
      r_delete = link_to I18n.t("person.name_cards.index.actions.delete"), person_name_card_path(r),
        method: :delete, data: { confirm: "你确定要删除吗？" }
      r_start_approve = if r.begin_task_id.blank?
        link_to I18n.t("person.name_cards.index.actions.start_approve"), start_approve_person_name_card_path(r),
        class: "btn btn-primary", method: :patch, data: { disable_with: "处理中" }
      end
      { name: r_chinese_name,
        english_name: r.english_name,
        email: r.email,
        task_id: (r.begin_task_id.present? ? link_to(I18n.t("person.name_cards.index.actions.look_workflow"), person_name_card_path(id: r.id, begin_task_id: r.begin_task_id), remote: true) : ""),
        department_name: r.department_name,
        en_department_name: r.en_department_name,
        title: r.title,
        en_title: r.en_title,
        mobile: r.mobile,
        phone_ext: r.phone_ext,
        fax_no: r.fax_no,
        print_out_box_number: r.print_out_box_number,
        status: r.status,
        item_action: if @current_user.email.end_with?('@thape.com.cn')
            "#{r_delete}#{r_start_approve}".html_safe
          end
      }
    end
  end

  def get_raw_records
    if @only_see_approved
      @name_card_applies.where(status: '同意')
    else
      @name_card_applies
    end
  end
end
