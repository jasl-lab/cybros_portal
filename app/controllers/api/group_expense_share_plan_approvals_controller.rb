# frozen_string_literal: true

module API
  class GroupExpenseSharePlanApprovalsController < ActionController::API
    def create
      return render json: { is_success: 403, error_message: '此 API 仅允许内网调用。' }, status: :forbidden unless request.remote_ip.start_with?('172.16.') || request.remote_ip.start_with?('10.35.') || request.remote_ip == '127.0.0.1'
      gespa = SplitCost::GroupExpenseSharePlanApproval.find_by id: params[:approval_id]
      return render json: { is_success: 404, error_message: '找不到审批ID对应的审批记录。' }, status: :not_found unless gespa.present?

      comments = params[:comments]
      comments.each do |result|
        company_code = result[:company_code]
        approval_message = result[:opinion]
        approver_clerk_code = result[:approver_code]

        cma = gespa.cost_split_company_monthly_adjusts.find_or_create_by(month: gespa.month, to_split_company_code: company_code)
        cma.approval_message = approval_message
        cma.user_id = User.find_by clerk_code: approver_clerk_code
        cma.status = if params[:approval_result].to_i == 1
          '同意'
        else
          '否决'
        end
        cma.save
      end

      render json: { is_success: true }, status: :ok
    end
  end
end
