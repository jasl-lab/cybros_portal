# frozen_string_literal: true

namespace :export_lat_lng do
  desc 'Export the CSV file'
  task :csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[project_id marketinfoname company coordinate suggested_coordinate]
      Bi::NewMapInfo.where.not(coordinate: nil).where("COORDINATE NOT LIKE '%,%'").each do |n|
        puts n.id
        g = Geocoder.search("#{n.company}#{n.marketinfoname}")
        if g.first.present?
          values = []
          values << n.id
          values << n.marketinfoname
          values << n.company
          values << n.coordinate
          values << g.first.coordinates.reverse.join(',')
          csv << values
        end
      end
    end
  end
end
