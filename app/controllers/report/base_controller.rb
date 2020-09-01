# frozen_string_literal: true

class Report::BaseController < ApplicationController
  NON_CONSTRUCTION_COMPANYS = %w[AICO室内 上海室内 深圳室内 天华景观 上海规划 互娱科技 武汉室内]
  after_action :record_user_view_history, if: -> { current_user.present? }

  def cors_set_access_control_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET"
    headers["Access-Control-Request-Method"] = "*"
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, Authorization"
    headers["X-Frame-Options"] = "ALLOW-FROM http://172.16.1.159"
    headers["X-XSS-Protection"] = "0"
  end

  def prepare_encrypt_uid
    login_name = current_user.email.split('@')[0]
    time_stamp = Time.now.to_i
    @uid = AesEncryptDecrypt.encryption("#{login_name}:#{time_stamp}")
  end

  def record_user_view_history
    current_user.report_view_histories.create(controller_name: controller_path, action_name: action_name)
  end
end
