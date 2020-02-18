# frozen_string_literal: true

module Person
  class CopyOfBusinessLicensesController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_copy_of_business_license_apply, only: %i[show destroy start_approve view_attachment]

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

    def show
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
        json: { processName: '', incident: '', taskId: @copy_of_business_license_apply.begin_task_id })
      Rails.logger.debug "name cards apply history response: #{response}"
      @result = JSON.parse(response.body.to_s)
      render 'shared/show_task_detail'
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.copy_of_business_licenses.index.actions.new'), new_person_copy_of_business_license_path)
      @copy_of_business_license_apply = current_user.copy_of_business_license_applies.build
      @copy_of_business_license_apply.employee_name = current_user.chinese_name
      @copy_of_business_license_apply.clerk_code = current_user.clerk_code
      current_user_department = current_user.departments.first
      if current_user_department.present?
        @copy_of_business_license_apply.belong_company_name = current_user_department.company_name
        @copy_of_business_license_apply.belong_company_code = current_user_department.company_code
        @copy_of_business_license_apply.belong_department_name = current_user_department.name
        @copy_of_business_license_apply.belong_department_code = current_user_department.dept_code
        @copy_of_business_license_apply.contract_belong_company = current_user_department.company_name
        @copy_of_business_license_apply.contract_belong_company_code = current_user_department.company_code
      end
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
      if @copy_of_business_license_apply.begin_task_id.present? || @copy_of_business_license_apply.backend_in_processing
        redirect_to person_copy_of_business_licenses_path, notice: t('.repeated_approve_request')
        return
      end

      bizData = {
        sender: 'Cybros',
        cybros_form_id: "copy_of_business_license_apply_id_#{@copy_of_business_license_apply.id}",
        applicant_name: @copy_of_business_license_apply.employee_name,
        applicant_code: @copy_of_business_license_apply.clerk_code,
        application_type: 'personal',
        application_class: 'gsyyzz',
        work_company_name: @copy_of_business_license_apply.belong_company_name,
        work_company_code: @copy_of_business_license_apply.belong_company_code, # 申请人归属公司编码
        work_dept_name: @copy_of_business_license_apply.belong_department_name,
        work_dept_code: @copy_of_business_license_apply.belong_department_code, # 申请人所属部门编码
        lc_company_name: @copy_of_business_license_apply.contract_belong_company,
        lc_company_code: @copy_of_business_license_apply.contract_belong_company_code, # 申请人所属部门编码
        stamp_location_name: Personal::CopyOfBusinessLicenseApply.sh_stamp_place.key(@copy_of_business_license_apply.stamp_to_place),
        stamp_location_code: @copy_of_business_license_apply.stamp_to_place,
        application_reason: @copy_of_business_license_apply.stamp_comment,
        attachment_list: [ { file_name: @copy_of_business_license_apply.attachment.filename.to_s, url: rails_blob_url(@copy_of_business_license_apply.attachment) } ],
        created_at: @copy_of_business_license_apply.created_at,
        updated_at: @copy_of_business_license_apply.updated_at
      }

      @copy_of_business_license_apply.update_columns(backend_in_processing: true)
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
        json: { processName: 'OfficialSealUsageApplication', taskId: '', action: '', comments: '', step: 'Begin',
        userCode: current_user.clerk_code, bizData: bizData.to_json })
      Rails.logger.debug "OfficialSealUsage CopyOfBusinessLicenseApply handler response: #{response}"
      result = JSON.parse(response.body.to_s)
      @copy_of_business_license_apply.update_columns(backend_in_processing: false)

      if result['isSuccess'] == '1'
        @copy_of_business_license_apply.update(begin_task_id: result['BeginTaskId'])
        redirect_to person_copy_of_business_licenses_path, notice: t('.success')
      else
        @copy_of_business_license_apply.update(bpm_message: result['message'])
        redirect_to person_copy_of_business_licenses_path, notice: t('.failed', message: result['message'])
      end
    end

    def view_attachment
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
          .permit(:employee_name, :clerk_code,
            :belong_company_name, :belong_company_code,
            :belong_department_name, :belong_department_code,
            :contract_belong_company, :contract_belong_company_code,
            :stamp_to_place, :attachment, :stamp_comment)
      end
  end
end
