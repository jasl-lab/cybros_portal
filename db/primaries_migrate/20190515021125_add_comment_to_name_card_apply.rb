class AddCommentToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :comment, :string
  end
end
