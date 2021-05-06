class RemoveUserJotTypeIdFromUserSplitClassifySalary < ActiveRecord::Migration[6.1]
  def change
    remove_reference :user_split_classify_salaries, :user_job_type
  end
end
