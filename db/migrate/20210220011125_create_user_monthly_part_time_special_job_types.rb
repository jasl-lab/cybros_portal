class CreateUserMonthlyPartTimeSpecialJobTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :user_monthly_part_time_special_job_types do |t|
      t.date :month, null: false
      t.references :user, null: false, foreign_key: true
      t.references :position, null: false, foreign_key: true
      t.references :user_job_type, null: false, foreign_key: true, index: { name: 'idx_user_monthly_part_time_special_job_types_on_user_job_type' }

      t.timestamps
    end

    SplitCost::UserMonthlyPartTimeSpecialJobType.create(month: Time.now.beginning_of_month, 
      user: User.first, position: User.first.positions.first, user_job_type: SplitCost::UserJobType.first)
  end
end
