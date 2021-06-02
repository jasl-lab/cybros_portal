class AddNcPkPostToPositionToUserSplitClassifySalary < ActiveRecord::Migration[6.1]
  def change
    add_column :user_split_classify_salaries, :nc_pk_post, :string
  end
end
