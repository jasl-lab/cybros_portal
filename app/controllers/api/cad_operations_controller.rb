# frozen_string_literal: true

module API
  class CadOperationsController < ApplicationController
    before_action :authenticate_user!

    def create
      seg = params[:cmd_data]['segmentation']

      seg_name_pair = seg.find { |s| s['Key'] == '名称' }
      seg_name = if seg_name_pair.present?
        seg_name_pair['Value']
      end

      seg_function_pair = seg.find { |s| s['Key'] == '功能' }
      seg_function = if seg_function_pair.present?
        seg_function_pair['Value']
      end

      seg_user_pair = seg.find { |s| s['Key'] == '用户' }
      seg_pre_sso_id = if seg_user_pair.present?
        seg_user_pair['Value']
      end

      seg_project_pair = seg.find { |s| s['Key'] == '项目' }
      seg_project_code = if seg_project_pair.present?
        seg_project_pair['Value']
      end

      user = if seg_pre_sso_id.present?
        User.find_by(pre_sso_id: seg_pre_sso_id) || current_user
      else
        current_user
      end

      cad_operation = user.cad_operations.create(
        session_id: params[:session_id],
        cmd_name: params[:cmd_name],
        cmd_seconds: params[:cmd_seconds],
        cmd_data: params[:cmd_data].to_json,
        seg_name: seg_name,
        seg_function: seg_function,
        seg_project_code: seg_project_code
      )
      if cad_operation.persisted?
        head :created
      else
        render json: { error: cad_operation.errors.full_messages }, status: :bad_request
      end
    end
  end
end
