class AddOwerIdToPendingQuestion < ActiveRecord::Migration[6.0]
  def change
    add_reference :pending_questions, :owner, null: true
  end
end
