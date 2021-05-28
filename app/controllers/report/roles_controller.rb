# frozen_string_literal: true

class Report::RolesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    authorize Role
    prepare_meta_tags title: t('.title')
    @roles = policy_scope(Role).all
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
end
