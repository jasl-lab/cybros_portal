# frozen_string_literal: true

class Admin::ManualOperationAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[create destroy]

  def index
    @code_1 = ManualOperationAccessCode.where(code: User::ALL_OF_ALL)
    @code_2 = ManualOperationAccessCode.where(code: User::ALL_EXCEPT_OTHER_COMPANY_DETAILS)
    @code_3 = ManualOperationAccessCode.where(code: User::MY_COMPANY_ALL_DETAILS)
    @code_4 = ManualOperationAccessCode.where(code: User::MY_COMPANY_EXCEPT_OTHER_DEPTS)
    @code_5 = ManualOperationAccessCode.where(code: User::MY_DEPARTMENT)
  end

  def create
    @user.manual_operation_access_codes.create(manual_operation_access_code_params)
    redirect_to admin_user_path(id: @user.id), notice: '市场运营的权限访问码已新建。'
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
