# frozen_string_literal: true

module Company
  class TianZhenLoginCount < ApplicationRecord
    def self.record_count
      response = HTTP.cookies('bsAutoLogin' => 'BIT_TRUE',
        'bsPassword' => '',
        'bsSessionID' => Rails.application.credentials.tianzhen_admin_session_id!,
        'bsUser' => Rails.application.credentials.tianzhen_admin_username!)
        .get(Rails.application.credentials.tianzhen_admin_web_url!)
      login_count = if response.code == 200
        html_doc = Nokogiri::HTML(response.body.to_s)
        trs = html_doc.xpath('//*[@id="content_middle"]/table/tbody/tr')
        trs.count
      end
      create(login_count: login_count)
    end
  end
end
