class CreateCommentOnProjectItemCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_on_project_item_codes do |t|
      t.string :project_item_code
      t.string :comment
      t.date :record_month

      t.timestamps
    end
  end
end
