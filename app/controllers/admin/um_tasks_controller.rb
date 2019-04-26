class Admin::UmTasksController < Admin::ApplicationController
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @process_name = params[:process_name]&.strip
    @assigned_to_user = params[:assigned_to_user]&.strip
    @tasks = UltDb::Task.get_tasks(@process_name, @assigned_to_user)
    @all_process_name = UltDb::Task.all_process_name
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [{
                       text: t("layouts.sidebar.admin.um_tasks"),
                       link: admin_um_tasks_path
                     }]
  end
end
