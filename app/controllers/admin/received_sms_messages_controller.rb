# frozen_string_literal: true

module Admin
  class ReceivedSmsMessagesController < ApplicationController
    def index
      prepare_meta_tags title: t('.title')
    end
  end
end
