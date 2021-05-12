class ChangeRateToDecimalForUserMonthlyPartTimeSplitRateTo6 < ActiveRecord::Migration[6.1]
  def change
    change_column :user_monthly_part_time_split_rates, :salary_classification_split_rate, :decimal, precision: 10, scale: 6
  end
end
