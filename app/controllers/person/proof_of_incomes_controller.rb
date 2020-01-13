# frozen_string_literal: true

module Person
  class ProofOfIncomesController < ApplicationController
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
      add_to_breadcrumbs(t('person.proof_of_employments.index.actions.new'), new_person_proof_of_employment_path)
      @proof_of_income_apply = current_user.proof_of_income_applies.build
      @proof_of_income_apply.employee_name = current_user.chinese_name
      @proof_of_income_apply.belong_company_name = current_user.departments.first&.company_name
      @proof_of_income_apply.belong_department_name = current_user.departments.first&.name
      @proof_of_income_apply.contract_belong_company = current_user.departments.first&.company_name
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
        { text: t('layouts.sidebar.person.proof_of_income'),
          link: person_proof_of_incomes_path }]
      end
  end
end
