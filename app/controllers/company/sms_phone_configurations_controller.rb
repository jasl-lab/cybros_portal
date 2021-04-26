# frozen_string_literal: true

class Company::SmsPhoneConfigurationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_sms_phone_mapping, only: [:edit, :update]

  def index
    prepare_meta_tags title: t('.title')
    @sms_phone_mappings = Company::SmsPhoneMapping.all
  end

  def edit
  end

  def update
    @sms_phone_mapping.update(sms_phone_mapping_params)
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'company'
    end

  private

    def set_sms_phone_mapping
      @sms_phone_mapping = Company::SmsPhoneMapping.find(params[:id])
      authorize @sms_phone_mapping
    end

    def sms_phone_mapping_params
      params.require(:company_sms_phone_mapping).permit(:user_id, :user_mobile)
    end
end
