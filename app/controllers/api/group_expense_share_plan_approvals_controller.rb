# frozen_string_literal: true

module API
  class GroupExpenseSharePlanApprovalsController < ActionController::API
    def create
      gespa = SplitCost::GroupExpenseSharePlanApproval.find_by id: params[:approval_id]
      return render json: { is_success: 404, error_message: '找不到审批ID对应的审批记录。' }, status: :not_found unless gespa.present?

      approval_month = Date.parse(params[:approval_month])
      return render json: { is_success: 409, error_message: '审批ID与审批月份不匹配。' }, status: :conflict unless gespa.month == approval_month

      cma = gespa.cost_split_company_monthly_adjusts.find_by(to_split_company_code: params[:company_code])
      return render json: { is_success: 404, error_message: '找不到company_code对应的审批明细记录。' }, status: :not_found unless cma.present?

      cma.approval_message = params[:bpm_message]
      if params[:approval_result].to_i == 1
        cma.status = '同意'
      else
        cma.status = '否决'
      end

      if cma.save(validate: false)
        render json: { is_success: true }, status: :ok
      else
        render json: { is_success: 400, error_message: gespa.errors.full_messages }, status: :bad_request
      end
    end
  end
end
