# frozen_string_literal: true

class Admin::ManualOperationAccessCodesController < Admin::ApplicationController
  def index
    prepare_meta_tags title: t('.title')
    @code_1 = ManualOperationAccessCode.where(code: User::ALL_OF_ALL)
    @code_2 = ManualOperationAccessCode.where(code: User::ALL_EXCEPT_OTHER_COMPANY_DETAILS)
    @code_3 = ManualOperationAccessCode.where(code: User::MY_COMPANY_ALL_DETAILS)
    @code_4 = ManualOperationAccessCode.where(code: User::MY_COMPANY_EXCEPT_OTHER_DEPTS)
    @code_5 = ManualOperationAccessCode.where(code: User::MY_DEPARTMENT)
  end

  def create
    user = User.find(params[:user_id])
    user.manual_operation_access_codes.create(manual_operation_access_code_params)
    user.touch
    redirect_to admin_user_path(id: user.id), notice: '市场运营的权限访问码已新建。'
  end

  def destroy
    user = if params[:user_id].present?
      User.find(params[:user_id])
    else
      ManualOperationAccessCode.find(params[:id]).user
    end

    moac = user.manual_operation_access_codes.find_by!(id: params[:id])
    moac.destroy

    user.touch
    if params[:user_id].present?
      redirect_to admin_user_path(id: user.id), notice: '市场运营的权限访问码已删除。'
    else
      redirect_to admin_manual_operation_access_codes_path, notice: '市场运营的权限访问码已删除。'
    end
  end

  private

    def manual_operation_access_code_params
      params.require(:manual_operation_access_code).permit(:code, :org_code, :dept_code, :title, :job_level)
    end
end
