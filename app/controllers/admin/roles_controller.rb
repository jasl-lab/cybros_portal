# frozen_string_literal: true

class Admin::RolesController < Admin::ApplicationController
  before_action :set_role, only: %i[show]
  before_action :set_breadcrumbs, only: %i[new edit create update], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")

    @roles = Role.all.page(params[:page]).per(params[:per_page])
  end

  def show
    prepare_meta_tags title: @role.role_name
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
