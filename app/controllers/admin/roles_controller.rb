# frozen_string_literal: true

class Admin::RolesController < Admin::ApplicationController
  before_action :set_role, only: %i[show user update]
  before_action :set_breadcrumbs, only: %i[new edit create update], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @roles = Role.all
  end

  def show
    prepare_meta_tags title: @role.role_name
    @ncworkno = params[:ncworkno]

    @users = @role.users.includes(:departments)
    @users_auto = case @role.id
                  when 6  # 查看项目地图并允许下载合同
                    contract_map_access_where = BaselinePositionAccess.contract_map_accesses[:project_detail_with_download]
                    position_ids = Position.joins(:baseline_position_access).where(baseline_position_access: { contract_map_access: contract_map_access_where }).pluck(:id)
                    User.joins(:position_users).where(position_users: { position_id: position_ids }).distinct
                  when 30 # 查看项目地图与合同信息
                    contract_map_access_where = [BaselinePositionAccess.contract_map_accesses[:project_detail_with_download], BaselinePositionAccess.contract_map_accesses[:view_project_details]]
                    position_ids = Position.joins(:baseline_position_access).where(baseline_position_access: { contract_map_access: contract_map_access_where }).pluck(:id)
                    User.joins(:position_users).where(position_users: { position_id: position_ids }).distinct
                  else
                    []
    end
  end

  def update
    to_add_user = User.find_by(clerk_code: params[:ncworkno])
    @role.role_users.find_or_create_by(user: to_add_user)
    redirect_to admin_role_path(id: @role.id), notice: t('.update_succss')
  end

  def user
    to_remove_user = User.find(params[:user_id])
    @role.role_users.find_by(user_id: to_remove_user.id)&.destroy
    redirect_to admin_role_path(id: @role.id), notice: t('.remove_succss')
  end

  private

    def set_role
      @role = Role.find(params[:id])
    end

    def set_breadcrumbs
      @_breadcrumbs = [{
                         text: t('layouts.sidebar.admin.users'),
                         link: admin_users_path
                       }]
    end
end
