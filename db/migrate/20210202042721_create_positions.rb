class CreatePositions < ActiveRecord::Migration[6.1]
  def change
    create_table :positions do |t|
      t.string :name
      t.string :functional_category
      t.references :department, null: true

      t.timestamps
    end
    create_table :position_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :position, null: false, foreign_key: true
      t.boolean :main_position
      t.string :post_level
      t.references :user_job_type, null: true

      t.timestamps
    end
  end
end
