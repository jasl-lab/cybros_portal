# frozen_string_literal: true

class Company::HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'company'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.company.header'),
        link: company_root_path }]
    end
end
