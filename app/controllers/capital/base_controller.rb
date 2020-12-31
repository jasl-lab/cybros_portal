# frozen_string_literal: true

class Capital::BaseController < ApplicationController
  after_action :record_user_view_history, if: -> { current_user.present? }

  def prepare_encrypt_uid
    login_name = current_user.email.split('@')[0]
    time_stamp = Time.now.to_i
    @uid = AesEncryptDecrypt.encryption("#{login_name}:#{time_stamp}")
  end

  def record_user_view_history
    current_user.report_view_histories.create(controller_name: controller_path, action_name: action_name)
  end
end
