# frozen_string_literal: true

module Person
  class PublicRentalHousingsController < ApplicationController
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
      add_to_breadcrumbs(t('person.public_rental_housings.index.actions.new'), new_person_public_rental_housing_path)
      @public_rental_housing_apply = current_user.public_rental_housing_applies.build
      @public_rental_housing_apply.employee_name = current_user.chinese_name
      @public_rental_housing_apply.belong_company_name = current_user.departments.first&.company_name
      @public_rental_housing_apply.belong_department_name = current_user.departments.first&.name
      @public_rental_housing_apply.contract_belong_company = current_user.departments.first&.company_name
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
        { text: t('layouts.sidebar.person.public_rental_housing'),
          link: person_public_rental_housings_path }]
      end
  end
end
