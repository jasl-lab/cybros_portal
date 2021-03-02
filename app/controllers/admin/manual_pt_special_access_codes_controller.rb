# frozen_string_literal: true

class Admin::ManualPtSpecialAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[create destroy]

  def create
    @user.part_time_special_access_codes.create(manual_pts_access_code_params)
    @user.touch
    redirect_to admin_user_path(id: @user.id), notice: '特殊人员薪资项目成本分类设置的访问权限已新建。'
  end

  def destroy
    ptsac = @user.part_time_special_access_codes.find_by!(id: params[:id])
    ptsac.destroy
    @user.touch
    redirect_to admin_user_path(id: @user.id), notice: '特殊人员薪资项目成本分类设置的访问权限已删除。'
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end

    def manual_pts_access_code_params
      params.require(:part_time_special_access_code).permit(:org_code)
    end
end
