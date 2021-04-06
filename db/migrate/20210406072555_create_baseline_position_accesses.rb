class CreateBaselinePositionAccesses < ActiveRecord::Migration[6.1]
  def change
    create_table :baseline_position_accesses do |t|
      t.string :b_postcode
      t.string :b_postname
      t.integer :contract_map_access, default: 0

      t.timestamps
    end
  end
end
