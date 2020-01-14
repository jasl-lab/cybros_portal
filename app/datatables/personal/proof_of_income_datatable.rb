# frozen_string_literal: true

module Personal
  class ProofOfIncomeDatatable < ApplicationDatatable
    def_delegator :@view, :person_proof_of_income_path
    def_delegator :@view, :start_approve_person_proof_of_income_path

    def initialize(params, opts = {})
      @proof_of_income_applies = opts[:proof_of_income_applies]
      super
    end

    def view_columns
      @view_columns ||= {
        employee_name: { source: 'Personal::ProofOfIncomeApply.employee_name', cond: :like, searchable: true, orderable: true },
        clerk_code: { source: 'Personal::ProofOfIncomeApply.clerk_code', cond: :like, searchable: true, orderable: true },
        belong_company_name: { source: 'Personal::ProofOfIncomeApply.belong_company_name', cond: :like, searchable: true, orderable: true },
        belong_department_name: { source: 'Personal::ProofOfIncomeApply.belong_department_name', cond: :like, searchable: true, orderable: true },
        contract_belong_company: { source: 'Personal::ProofOfIncomeApply.contract_belong_company', cond: :like, searchable: true, orderable: true },
        stamp_to_place: { source: 'Personal::ProofOfIncomeApply.stamp_to_place', cond: :like, searchable: true, orderable: true },
        stamp_comment: { source: 'Personal::ProofOfIncomeApply.stamp_comment', cond: :like, searchable: true, orderable: true },
        item_action: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        r_delete = link_to I18n.t('person.proof_of_incomes.index.actions.delete'), person_proof_of_income_path(r),
          method: :delete, data: { confirm: '你确定要删除吗？' }
        r_start_approve = link_to I18n.t('person.proof_of_incomes.index.actions.start_approve'), start_approve_person_proof_of_income_path(r),
          class: 'btn btn-primary', method: :patch, data: { disable_with: '处理中' }
        { employee_name: r.employee_name,
          clerk_code: r.clerk_code,
          belong_company_name: r.belong_company_name,
          belong_department_name: r.belong_department_name,
          contract_belong_company: r.contract_belong_company,
          stamp_to_place: r.stamp_to_place,
          stamp_comment: r.stamp_comment,
          item_action: "#{r_delete}#{r_start_approve}".html_safe
        }
      end
    end

    def get_raw_records
      @proof_of_income_applies
    end
  end
end
