# frozen_string_literal: true

module ReportHelper
  def report_link_to(name = nil, options = {}, html_options = nil, &block)
    options[:target] = name.split('/')[2] if current_user&.open_in_new_tab
    link_to(name, options, html_options, &block)
  end
end
