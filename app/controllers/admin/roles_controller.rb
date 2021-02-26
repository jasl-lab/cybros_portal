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
    @ncworkno = params[:ncworkno] || User.first.clerk_code

    @users = @role.users.includes(:departments)
    @users_auto = case @role.id
                  when 6  # 查看项目地图并允许下载合同
                    User.joins(:departments).where(departments: { company_name: '上海天华建筑设计有限公司' })
                      .where(position_title: Bi::NewMapInfoPolicy::ALLOW_DOWNLOAD_HQ_TITLES)
                        .or(User.joins(:departments).where.not(departments: { company_name: '上海天华建筑设计有限公司' })
                      .where(position_title: Bi::NewMapInfoPolicy::ALLOW_DOWNLOAD_SUBSIDIARY_TITLES))
                  when 30 # 查看项目地图
                    User.where(position_title: Bi::NewMapInfoPolicy::ALLOW_SHOW_TITLES)
                  else
                    []
    end
  end

  def update
    to_add_user = User.find_by(clerk_code: params[:ncworkno])
    @role.role_users.create(user: to_add_user)
    redirect_to admin_role_path(id: @role.id)
  end

  def user
    to_remove_user = User.find(params[:user_id])
    @role.role_users.find_by(user_id: to_remove_user.id)&.destroy
    redirect_to admin_role_path(id: @role.id)
  end

  private

    # Use callbacks to share common setup or constraints between actions.
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
