# frozen_string_literal: true

class CostSplit::HumanResourcesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @all_company_names = Bi::OrgOrder.all_company_names
    @company_name = current_user.user_company_names.first
    @dept_options = []
    @depts = []
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.cost_split.header'),
        link: cost_split_root_path },
      { text: t('layouts.sidebar.cost_split.human_resource'),
        link: cost_split_human_resources_path }]
    end
end
