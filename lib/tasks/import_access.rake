# frozen_string_literal: true

namespace :import_access do
  desc 'Import baseline position access'
  task :baseline_position, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      b_postcode = row['岗位编码']
      csv_b_postname = row['岗位名称']
      contract_map_access = row['项目地图权限'].to_i
      puts "#{b_postcode}:#{contract_map_access}"
      real_contract_map_access = if contract_map_access == 1
        'project_detail_with_download'
      elsif contract_map_access == 2
        'view_project_details'
      else
        'view_project_only'
      end
      b_postname = Position.find_by(b_postcode: b_postcode)&.b_postname

      bpa = BaselinePositionAccess.find_or_create_by(b_postcode: b_postcode)
      bpa.update(b_postname: b_postname.presence || csv_b_postname, contract_map_access: real_contract_map_access)
    end
  end
end
