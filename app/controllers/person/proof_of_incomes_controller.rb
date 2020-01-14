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
        format.json do
          proof_of_income_applies = policy_scope(Personal::ProofOfIncomeApply).all
          render json: Personal::ProofOfIncomeDatatable.new(params,
            proof_of_income_applies: proof_of_income_applies,
            view_context: view_context)
        end
      end
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.proof_of_incomes.index.actions.new'), new_person_proof_of_income_path)
      @proof_of_income_apply = current_user.proof_of_income_applies.build
      @proof_of_income_apply.employee_name = current_user.chinese_name
      @proof_of_income_apply.clerk_code = current_user.clerk_code
      @proof_of_income_apply.belong_company_name = current_user.departments.first&.company_name
      @proof_of_income_apply.belong_department_name = current_user.departments.first&.name
      @proof_of_income_apply.contract_belong_company = current_user.departments.first&.company_name
    end

    def create
      @proof_of_income_apply = current_user.proof_of_income_applies.build(proof_of_income_apply_params)
      respond_to do |format|
        if @proof_of_income_apply.save
          format.html { redirect_to person_proof_of_incomes_path, notice: t('.success') }
        else
          format.html { render :new }
        end
      end
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

      def proof_of_income_apply_params
        params.require(:personal_proof_of_income_apply)
          .permit(:employee_name, :clerk_code, :belong_company_name,
            :belong_department_name, :contract_belong_company, :stamp_to_place, :stamp_comment)
      end
  end
end
