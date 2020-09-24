# frozen_string_literal: true

namespace :report do
  desc 'Filling report name with locales title'
  task filling_names: :environment do
    ReportViewHistory.select(:controller_name, :action_name).distinct.each do |t|
      space_name = t.controller_name.split('/').first
      controller = t.controller_name.split('/').last
      action = t.action_name
      puts I18n.t("#{space_name}.#{controller}.#{action}.title")
    end
  end
end
