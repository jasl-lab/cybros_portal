# frozen_string_literal: true

module Person
  class PublicRentalHousingsController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_proof_of_income_apply, only: %i[destroy start_approve]

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
        format.json do
          public_rental_housing_applies = policy_scope(Personal::PublicRentalHousingApply).all
          render json: Personal::PublicRentalHousingDatatable.new(params,
            public_rental_housing_applies: public_rental_housing_applies,
            view_context: view_context)
        end
      end
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.public_rental_housings.index.actions.new'), new_person_public_rental_housing_path)
      @public_rental_housing_apply = current_user.public_rental_housing_applies.build
      @public_rental_housing_apply.employee_name = current_user.chinese_name
      @public_rental_housing_apply.clerk_code = current_user.clerk_code
      @public_rental_housing_apply.belong_company_name = current_user.departments.first&.company_name
      @public_rental_housing_apply.belong_department_name = current_user.departments.first&.name
      @public_rental_housing_apply.contract_belong_company = current_user.departments.first&.company_name
    end

    def create
      @public_rental_housing_apply = current_user.public_rental_housing_applies.build(public_rental_housing_apply_params)
      respond_to do |format|
        if @public_rental_housing_apply.save
          format.html { redirect_to person_public_rental_housings_path, notice: t('.success') }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      @public_rental_housing_apply.destroy
      respond_to do |format|
        format.html { redirect_to person_public_rental_housings_path, notice: t('.success') }
        format.json { head :no_content }
      end
    end

    def start_approve
    end

    private

      def set_proof_of_income_apply
        @public_rental_housing_apply = policy_scope(Personal::PublicRentalHousingApply).find(params[:id])
      end

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

      def public_rental_housing_apply_params
        params.require(:personal_public_rental_housing_apply)
          .permit(:employee_name, :clerk_code, :belong_company_name,
            :belong_department_name, :contract_belong_company, :stamp_to_place, :stamp_comment)
      end
  end
end
