class AddShanghaiOnlyToKnowledge < ActiveRecord::Migration[6.0]
  def change
    add_column :knowledges, :shanghai_only, :boolean, default: false
  end
end
