# frozen_string_literal: true

module Users::AccessCode
  class PartTimeSplitUser < Micro::Case::Strict
    attributes :current_user, :to_filter_users_ids

    def call!
      access_users = if current_user.part_time_split_access_codes.present?
        cu = User.joins(user_monthly_part_time_split_rates: { position: :department })
        current_user.part_time_split_access_codes.each_with_index do |ac, index|
          if index == 0
            cu = if ac.dept_category.present?
              cu.where(user_monthly_part_time_split_rates: { main_position: true })
                .where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } } })
            else
              cu.where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code } } })
            end
          else
            cu = cu.or(if ac.dept_category.present?
                   cu.where(user_monthly_part_time_split_rates: { main_position: true })
                     .where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } } })
                 else
                   cu.where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code } } })
                 end)
          end
        end
        if to_filter_users_ids.present?
          cu.where(id: to_filter_users_ids).distinct # because users table joins.
        else
          cu
        end
      elsif to_filter_users_ids.present?
        User.where(id: to_filter_users_ids)
      else
        User
      end

      Success result: { access_users: access_users }
    end
  end
end
