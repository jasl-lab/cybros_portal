class AddUserJobTypeToUserMonthlyPartTimeSplitRate < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_monthly_part_time_split_rates, :user_job_type, null: true, index: false
  end
end
