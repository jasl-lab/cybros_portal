# frozen_string_literal: true

module Users::AccessCode
  class LaborCostUser < Micro::Case::Strict
    attributes :current_user

    def call!
      access_users = if current_user.part_time_split_access_codes.present?
        cu = User.joins(:departments)
        current_user.part_time_split_access_codes.each_with_index do |ac, index|
          if index == 0
            cu = if ac.dept_category.present?
              cu.where(departments: { company_code: ac.org_code, dept_category: ac.dept_category })
            else
              cu.where(departments: { company_code: ac.org_code })
            end
          else
            cu = cu.or(if ac.dept_category.present?
                   cu.where(departments: { company_code: ac.org_code, dept_category: ac.dept_category })
                 else
                   cu.where(departments: { company_code: ac.org_code })
                 end)
          end
        end
        cu.distinct # because users table joins.
      else
        User.none
      end

      Success result: { access_users: access_users }
    end
  end
end
