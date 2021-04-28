# frozen_string_literal: true

class Company::JointReviewSmsController < ApplicationController
  wechat_api
  before_action :make_sure_wechat_user_login, only: %i[index]

  def index
    prepare_meta_tags title: t('.title')
    @received_sms_messages = Company::ReceivedSmsMessage.where(created_at: 5.minutes.ago..).order(id: :desc)
  end
end
