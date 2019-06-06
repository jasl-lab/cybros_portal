require 'csv'

namespace :filling do
  desc 'Filling CSV file to subsidiary_workloadings'
  task :subsidiary_workloadings, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      Bi::SubsidiaryWorkloading.create(
        company: row['公司'],
        date: row['日期'],
        need_days: row['天数需填'],
        acturally_days: row['天数实填'],
        planning_need_days: row['方案需填'],
        planning_acturally_days: row['方案实填'],
        building_need_days: row['施工图需填'],
        building_acturally_days: row['施工图实填'],
      )
    end
  end
end
