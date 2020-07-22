# frozen_string_literal: true

class Admin::ManualOperationAccessCodesController < Admin::ApplicationController
  before_action :set_user, only: %i[destroy]

  def destroy
    moac = @user.manual_operation_access_codes.find_by!(id: params[:id])
    moac.destroy
    redirect_to admin_user_path(id: @user.id), notice: '市场运营的权限访问码已删除。'
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end
end
