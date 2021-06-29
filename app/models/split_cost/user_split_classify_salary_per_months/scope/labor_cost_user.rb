# frozen_string_literal: true

module SplitCost::UserSplitClassifySalaryPerMonths::Scope
  class LaborCostUser < Micro::Case::Strict
    attributes :current_user

    def call!
      cspm = if current_user.part_time_split_access_codes.present?
        cspm = SplitCost::UserSplitClassifySalaryPerMonth.joins(position: :department)
        current_user.part_time_split_access_codes.each_with_index do |ac, index|
          if index == 0
            cspm = if ac.dept_category.present?
              cspm.where(positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } })
            else
              cspm.where(positions: { departments: { company_code: ac.org_code } })
            end
          else
            cspm = cspm.or(if ac.dept_category.present?
                     cspm.where(positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } })
                   else
                     cspm.where(positions: { departments: { company_code: ac.org_code } })
                   end)
          end
        end
        cspm.distinct # because users table joins.
      else
        SplitCost::UserSplitClassifySalaryPerMonth.none
      end

      Success result: { user_split_classify_salary_per_months: cspm }
    end
  end
end
