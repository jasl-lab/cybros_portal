class Admin::UmTasksController < Admin::ApplicationController
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @tasks = UltDb::Task.all_tasks
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [{
                       text: t("layouts.sidebar.admin.um_tasks"),
                       link: admin_um_tasks_path
                     }]
  end
end
