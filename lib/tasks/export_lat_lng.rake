namespace :export_lat_lng do
  desc "Export the CSV file"
  task :csv, [:csv_file_path] => [:environment] do |_task, args|
    csv_file_path = args[:csv_file_path]
    CSV.open(csv_file_path, 'w') do |csv|
      csv << %w[project_id marketinfoname company coordinate suggested_coordinate]
      Bi::NewMapInfo.where.not(coordinate: nil).where("COORDINATE NOT LIKE '%,%'").each do |n|
        puts n.id
        values = []
        values << n.id
        values << n.marketinfoname
        values << n.company
        values << n.coordinate
        g = Geocoder.search("#{n.company}#{n.marketinfoname}")
        values << (if g.first.present?
          g.first.coordinates.reverse.join(',')
        else
          ''
        end)
        csv << values
      end
    end
  end
end
