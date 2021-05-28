# frozen_string_literal: true

class Report::RolesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :set_role, only: %i[show user update]

  def index
    authorize Role
    prepare_meta_tags title: t('.title')
    @roles = policy_scope(Role).all
  end

  def show
    prepare_meta_tags title: @role.role_name
    authorize @role
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
    authorize @role
    to_add_user = User.find_by(clerk_code: params[:ncworkno])
    @role.role_users.find_or_create_by(user: to_add_user)
    redirect_to report_role_path(id: @role.id), notice: t('.update_succss')
  end

  def user
    authorize @role
    to_remove_user = User.find(params[:user_id])
    @role.role_users.find_by(user_id: to_remove_user.id)&.destroy
    redirect_to report_role_path(id: @role.id), notice: t('.remove_succss')
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'human_resource'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.human_resource.header'),
        link: report_human_resource_path },
            { text: t('layouts.sidebar.report.roles'),
        link: report_roles_path }]
    end

  private

    def set_role
      @role = policy_scope(Role).find(params[:id])
    end
end
