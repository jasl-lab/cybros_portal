class AddApplicationClassAndSubClassToOfficialStampUsage < ActiveRecord::Migration[6.0]
  def change
    remove_column :official_stamp_usage_applies, :application_subclass_list, :string
    add_column :official_stamp_usage_applies, :application_subclasses, :string, default: [].to_yaml
  end
end
