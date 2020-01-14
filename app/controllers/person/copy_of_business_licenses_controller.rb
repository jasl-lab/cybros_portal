# frozen_string_literal: true

module Person
  class CopyOfBusinessLicensesController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
      end
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.copy_of_business_licenses.index.actions.new'), new_person_copy_of_business_license_path)
      @copy_of_business_license_apply = current_user.copy_of_business_license_applies.build
      @copy_of_business_license_apply.employee_name = current_user.chinese_name
      @copy_of_business_license_apply.clerk_code = current_user.clerk_code
      @copy_of_business_license_apply.belong_company_name = current_user.departments.first&.company_name
      @copy_of_business_license_apply.belong_department_name = current_user.departments.first&.name
      @copy_of_business_license_apply.contract_belong_company = current_user.departments.first&.company_name
    end

    private

      def set_page_layout_data
        @_sidebar_name = 'person'
      end

      def set_breadcrumbs
        @_breadcrumbs = [
        { text: t('layouts.sidebar.application.header'),
          link: root_path },
        { text: t('layouts.sidebar.person.header'),
          link: person_root_path },
        { text: t('layouts.sidebar.person.copy_of_business_license'),
          link: person_copy_of_business_licenses_path }]
      end
  end
end
