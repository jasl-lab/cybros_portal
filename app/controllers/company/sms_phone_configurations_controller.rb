# frozen_string_literal: true

class Company::SmsPhoneConfigurationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @sms_phone_mappings = Company::SmsPhoneMapping.all
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'company'
    end
end
