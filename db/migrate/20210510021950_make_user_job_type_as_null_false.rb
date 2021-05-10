class MakeUserJobTypeAsNullFalse < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:user_split_classify_salaries, :user_job_type_id, false)
  end
end
