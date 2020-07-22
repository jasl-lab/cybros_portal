# frozen_string_literal: true

class Admin::ManualOperationAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[create destroy]

  def create
    @user.manual_operation_access_codes.create(manual_operation_access_code_params)
    redirect_to admin_user_path(id: @user.id), notice: '市场运营的权限访问码已删除。'
  end

  def destroy
    moac = @user.manual_operation_access_codes.find_by!(id: params[:id])
    moac.destroy
    redirect_to admin_user_path(id: @user.id), notice: '市场运营的权限访问码已删除。'
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def manual_operation_access_code_params
      params.require(:manual_operation_access_code).permit(:code, :org_code, :dept_code, :title, :job_level)
    end
end
