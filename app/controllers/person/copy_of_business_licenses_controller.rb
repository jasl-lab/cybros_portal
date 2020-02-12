# frozen_string_literal: true

module Person
  class CopyOfBusinessLicensesController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_copy_of_business_license_apply, only: %i[destroy start_approve]

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
        format.json do
          copy_of_business_license_applies = policy_scope(Personal::CopyOfBusinessLicenseApply).all
          render json: Personal::CopyOfBusinessLicenseDatatable.new(params,
            copy_of_business_license_applies: copy_of_business_license_applies,
            view_context: view_context)
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

    def create
      @copy_of_business_license_apply = current_user.copy_of_business_license_applies.build(copy_of_business_license_apply_params)
      respond_to do |format|
        if @copy_of_business_license_apply.save
          format.html { redirect_to person_copy_of_business_licenses_path, notice: t('.success') }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      @copy_of_business_license_apply.destroy
      respond_to do |format|
        format.html { redirect_to person_copy_of_business_licenses_path, notice: t('.success') }
        format.json { head :no_content }
      end
    end

    def start_approve
    end

    private

      def set_copy_of_business_license_apply
        @copy_of_business_license_apply = policy_scope(Personal::CopyOfBusinessLicenseApply).find(params[:id])
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
        { text: t('layouts.sidebar.person.copy_of_business_license'),
          link: person_copy_of_business_licenses_path }]
      end

      def copy_of_business_license_apply_params
        params.require(:personal_copy_of_business_license_apply)
          .permit(:employee_name, :clerk_code, :belong_company_name,
            :belong_department_name, :contract_belong_company, :stamp_to_place, :attachment, :stamp_comment)
      end
  end
end
