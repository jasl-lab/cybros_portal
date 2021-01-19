# frozen_string_literal: true

module Admin
  class BiViewHistoriesController < ApplicationController
    before_action :prepare_encrypt_uid

    def show
      prepare_meta_tags title: t('.title')
      @redirect_url = 'view/form?viewlet=BI/VIEW_HISTORIES.frm&ref_t=design&ref_c=64b9edda-f7bb-4838-95bc-c69304833370'
      @hide_app_footer = true
      @hide_main_header_wrapper = true
      @hide_scroll = true
      render 'shared/report_show'
    end

    private

      def prepare_encrypt_uid
        login_name = current_user.email.split('@')[0]
        time_stamp = Time.now.to_i
        @uid = AesEncryptDecrypt.encryption("#{login_name}:#{time_stamp}")
      end
  end
end
