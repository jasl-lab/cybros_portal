# frozen_string_literal: true

module Company
  class OfficialStampUsagesController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_official_stamp_usage_apply, only: %i[show destroy start_approve view_attachment]

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
        format.json do
          official_stamp_usage_applies = policy_scope(Company::OfficialStampUsageApply).with_attached_attachments.all
          render json: Company::OfficialStampUsageDatatable.new(params,
            official_stamp_usage_applies: official_stamp_usage_applies,
            view_context: view_context)
        end
      end
    end

    def show
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
        json: { processName: '', incident: '', taskId: @official_stamp_usage_apply.begin_task_id })
      Rails.logger.debug "name cards apply history response: #{response}"
      @result = JSON.parse(response.body.to_s)
      render 'shared/show_task_detail'
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('company.official_stamp_usages.index.actions.new'), new_person_copy_of_business_license_path)
      @official_stamp_usage_apply = current_user.official_stamp_usage_applies.build
      @official_stamp_usage_apply.employee_name = current_user.chinese_name
      @official_stamp_usage_apply.clerk_code = current_user.clerk_code
      @official_stamp_usage_apply.application_class = '人力资源部'
      current_user_department = current_user.departments.first
      if current_user_department.present?
        @official_stamp_usage_apply.belong_company_name = current_user_department.company_name
        @official_stamp_usage_apply.belong_company_code = current_user_department.company_code
        @official_stamp_usage_apply.belong_department_name = current_user_department.name
        @official_stamp_usage_apply.belong_department_code = current_user_department.dept_code
      end
    end

    def create
      @official_stamp_usage_apply = current_user.official_stamp_usage_applies.build(official_stamp_usage_apply_params)
      respond_to do |format|
        if @official_stamp_usage_apply.save
          format.html { redirect_to company_official_stamp_usages_path, notice: t('.success') }
        else
          @application_subclasses = @official_stamp_usage_apply.application_subclasses
          format.html { render :new }
        end
      end
    end

    def destroy
      @official_stamp_usage_apply.destroy
      respond_to do |format|
        format.html { redirect_to company_official_stamp_usages_path, notice: t('.success') }
        format.json { head :no_content }
      end
    end

    def start_approve
      if @official_stamp_usage_apply.begin_task_id.present? || @official_stamp_usage_apply.backend_in_processing
        redirect_to company_official_stamp_usages_path, notice: t('.repeated_approve_request')
        return
      end

      attachment_list = @official_stamp_usage_apply.attachments.collect do |attachment|
        { file_name: attachment.filename.to_s,
          url: rails_blob_url(attachment) }
      end

      bizData = {
        sender: 'Cybros',
        cybros_form_id: "official_stamp_usage_apply_id_#{@official_stamp_usage_apply.id}",
        applicant_name: @official_stamp_usage_apply.employee_name,
        applicant_code: @official_stamp_usage_apply.clerk_code,
        application_type: 'administrative',
        application_class: Company::OfficialStampUsageApply.usage_code_map[@official_stamp_usage_apply.application_class.to_sym],
        application_subclass_list: @official_stamp_usage_apply.application_subclasses.reject(&:blank?),
        work_company_name: @official_stamp_usage_apply.belong_company_name,
        work_company_code: @official_stamp_usage_apply.belong_company_code, # 申请人归属公司编码
        work_dept_name: @official_stamp_usage_apply.belong_department_name,
        work_dept_code: @official_stamp_usage_apply.belong_department_code, # 申请人所属部门编码
        lc_company_name: nil,
        lc_company_code: nil, # 申请人所属部门编码
        stamp_location_name: Company::OfficialStampUsageApply.sh_stamp_place.key(@official_stamp_usage_apply.stamp_to_place),
        stamp_location_code: @official_stamp_usage_apply.stamp_to_place,
        application_reason: @official_stamp_usage_apply.stamp_comment,
        attachment_list: attachment_list,
        created_at: @official_stamp_usage_apply.created_at,
        updated_at: @official_stamp_usage_apply.updated_at
      }

      @official_stamp_usage_apply.update_columns(backend_in_processing: true)
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
        json: { processName: 'OfficialSealUsageApplication', taskId: '', action: '', comments: '', step: 'Begin',
        userCode: current_user.clerk_code, bizData: bizData.to_json })
      Rails.logger.debug "OfficialSealUsage OfficialStampUsageApply handler response: #{response}"
      result = JSON.parse(response.body.to_s)
      @official_stamp_usage_apply.update_columns(backend_in_processing: false)

      if result['isSuccess'] == '1'
        @official_stamp_usage_apply.update(begin_task_id: result['BeginTaskId'])
        redirect_to company_official_stamp_usages_path, notice: t('.success')
      else
        @official_stamp_usage_apply.update(bpm_message: result['message'])
        redirect_to company_official_stamp_usages_path, notice: t('.failed', message: result['message'])
      end
    end

    def view_attachment
      @attachment = @official_stamp_usage_apply.attachments.find_by!(id: params[:attachment_id])
    end

    def fill_application_subclasses
      @usage_list = Company::OfficialStampUsageApply.usage_list[params[:company_official_stamp_usage_apply][:application_class].to_sym]
    end

    private

      def set_official_stamp_usage_apply
        @official_stamp_usage_apply = policy_scope(Company::OfficialStampUsageApply).find(params[:id])
      end

      def set_page_layout_data
        @_sidebar_name = 'company'
      end

      def set_breadcrumbs
        @_breadcrumbs = [
        { text: t('layouts.sidebar.application.header'),
          link: root_path },
        { text: t('layouts.sidebar.company.header'),
          link: company_root_path },
        { text: t('layouts.sidebar.company.official_stamp_usage'),
          link: company_official_stamp_usages_path }]
      end

      def official_stamp_usage_apply_params
        params.require(:company_official_stamp_usage_apply)
          .permit(:employee_name, :clerk_code,
            :belong_company_name, :belong_company_code,
            :belong_department_name, :belong_department_code,
            :stamp_to_place, :application_class,
            :stamp_comment, attachments: [], application_subclasses: [])
      end
  end
end
