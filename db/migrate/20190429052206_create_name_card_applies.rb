class CreateNameCardApplies < ActiveRecord::Migration[6.0]
  def change
    create_table :name_card_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :english_name
      t.string :department_name
      t.string :en_department_name
      t.string :title
      t.string :en_title
      t.string :phone_ext
      t.string :office_level
      t.string :fax_no
      t.string :mobile
      t.integer :print_out_box_number

      t.string :begin_task_id
      t.text :bpm_message
      t.string :status # 审批中，未提交，审批通过，审批不通过

      t.timestamps
    end
  end
end
