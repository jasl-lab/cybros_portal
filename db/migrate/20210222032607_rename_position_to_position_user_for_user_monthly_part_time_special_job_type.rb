class RenamePositionToPositionUserForUserMonthlyPartTimeSpecialJobType < ActiveRecord::Migration[6.1]
  def change
    remove_reference :user_monthly_part_time_special_job_types, :position, foreign_key: true
    add_reference :user_monthly_part_time_special_job_types, :position_user, foreign_key: true, index: { name: 'idx_user_monthly_part_time_special_job_types_on_position_user_id' }

    SplitCost::UserMonthlyPartTimeSpecialJobType.first.update(position_user: User.first.position_users.first)
  end
end
