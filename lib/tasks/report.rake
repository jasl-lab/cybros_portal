# frozen_string_literal: true

namespace :report do
  desc 'Filling report name with locales title'
  task filling_names: :environment do
    ReportName.delete_all
    puts 'Generate report name, missing controller_name will generate below'
    ReportViewHistory.select(:controller_name, :action_name).where(action_name: %w[show]).distinct.each do |t|
      space_name = t.controller_name.split('/').first
      controller = t.controller_name.split('/').last
      action = t.action_name
      chinese_report_name = I18n.t("#{space_name}.#{controller}.#{action}.title", company: '子公司')
      if chinese_report_name.start_with? 'translation missing:'
        puts t.controller_name
      else
        ReportName.create(controller_name: t.controller_name, report_name: chinese_report_name)
      end
    end
  end
end
