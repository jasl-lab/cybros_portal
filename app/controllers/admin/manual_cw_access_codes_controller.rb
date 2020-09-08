# frozen_string_literal: true

class Admin::ManualCwAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[create destroy]

  def create
    @user.manual_cw_access_codes.create(manual_cw_access_code_params)
    @user.touch
    redirect_to admin_user_path(id: @user.id), notice: '财务的自定义角色权限已新建。'
  end

  def destroy
    mcac = @user.manual_cw_access_codes.find_by!(id: params[:id])
    mcac.destroy
    @user.touch
    redirect_to admin_user_path(id: @user.id), notice: '财务的自定义角色权限已删除。'
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def manual_cw_access_code_params
      params.require(:manual_cw_access_code).permit(:cw_rolename, :org_code, :dept_code)
    end
end
