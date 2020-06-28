# frozen_string_literal: true

class Admin::RolesController < Admin::ApplicationController
  before_action :set_role, only: %i[show user]
  before_action :set_breadcrumbs, only: %i[new edit create update], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")

    @roles = Role.all
  end

  def show
    prepare_meta_tags title: @role.role_name
    @users = @role.users.includes(:departments)
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
                         text: t("layouts.sidebar.admin.users"),
                         link: admin_users_path
                       }]
    end
end
