# frozen_string_literal: true

class YingjiankeOverrunUser < ApplicationRecord
  self.default_timezone = :local

  class << self
    include ActionView::Helpers::DateHelper

    def rows
      response = HTTP.cookies('bsAutoLogin' => 'BIT_TRUE',
        'bsPassword' => Rails.application.credentials.yingjianke_admin_password!,
        'bsSessionID' => Rails.application.credentials.yingjianke_admin_session_id!,
        'bsUser' => Rails.application.credentials.yingjianke_admin_username!)
        .get(Rails.application.credentials.yingjianke_admin_web_url!)
      if response.code == 200
        html_doc = Nokogiri::HTML(response.body.to_s)
        trs = html_doc.xpath('//*[@id="content_middle"]/table/tbody/tr')
        rows = []
        trs.each do |tr|
          mid = tr.attributes['data-mid'].value
          device = tr.elements[1].elements[0].content.strip
          user_name = device.split('@')[0]
          info = User.details_mapping.fetch(user_name, user_name)
          ip = tr.elements[2].content.strip
          login_time = DateTime.parse(tr.elements[3].content.strip)
          last_access_time = DateTime.parse(tr.elements[4].content.strip)
          stay_time = distance_of_time_in_words login_time, last_access_time
          rows << [info, login_time, last_access_time, stay_time, device, ip, mid]
        end
        rows
      end
    end
  end
end
