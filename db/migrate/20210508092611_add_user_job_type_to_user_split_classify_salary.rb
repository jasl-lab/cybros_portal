class AddUserJobTypeToUserSplitClassifySalary < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_split_classify_salaries, :user_job_type
  end
end
