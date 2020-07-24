# frozen_string_literal: true

class Admin::ManualHrAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[create destroy]

  def create
    @user.manual_hr_access_codes.create(manual_hr_access_code_params)
    redirect_to admin_user_path(id: @user.id), notice: 'HR的自定义角色权限已新建。'
  end

  def destroy
    mhac = @user.manual_hr_access_codes.find_by!(id: params[:id])
    mhac.destroy
    redirect_to admin_user_path(id: @user.id), notice: 'HR的自定义角色权限已删除。'
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def manual_hr_access_code_params
      params.require(:manual_hr_access_code).permit(:hr_rolename, :org_code, :dept_code)
    end
end
