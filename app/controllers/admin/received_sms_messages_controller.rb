# frozen_string_literal: true

module Admin
  class ReceivedSmsMessagesController < ApplicationController
    def index
      prepare_meta_tags title: t('.title')
      @received_sms_messages = Company::ReceivedSmsMessage.where(created_at: 5.minutes.ago..)
    end

    def destroy
      received_sms_message = Company::ReceivedSmsMessage.find(params[:id])
      received_sms_message.destroy
      redirect_to admin_received_sms_messages_path, notice: '已删除。'
    end
  end
end
