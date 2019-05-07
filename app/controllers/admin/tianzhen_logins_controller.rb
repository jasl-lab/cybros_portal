class Admin::TianzhenLoginsController < Admin::ApplicationController
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [{
                       text: t("layouts.sidebar.admin.tianzhen_logins"),
                       link: admin_tianzhen_logins_path
                     }]
  end
end
