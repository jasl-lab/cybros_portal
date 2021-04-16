# frozen_string_literal: true

module Admin
  class ReceivedSmsMessagesController < ApplicationController
    def index
      prepare_meta_tags title: t('.title')
      @received_sms_messages = Company::ReceivedSmsMessage.all
    end
  end
end
