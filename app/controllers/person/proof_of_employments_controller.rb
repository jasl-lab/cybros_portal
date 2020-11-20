# frozen_string_literal: true

module Person
  class ProofOfEmploymentsController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_proof_of_employment_apply, only: %i[show destroy start_approve view_attachment]

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
        format.json do
          proof_of_employment_applies = policy_scope(Personal::ProofOfEmploymentApply).with_attached_attachments.all
          render json: Personal::ProofOfEmploymentDatatable.new(params,
            proof_of_employment_applies: proof_of_employment_applies,
            view_context: view_context)
        end
      end
    end

    def show
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
        json: { processName: '', incident: '', taskId: @proof_of_employment_apply.begin_task_id })
      Rails.logger.debug "name cards apply history response: #{response}"
      @result = JSON.parse(response.body.to_s)
      render file: '/shared/show_task_detail', locals: { show_task_detail_return_path: person_proof_of_employments_path }
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.proof_of_employments.index.actions.new'), new_person_proof_of_employment_path)
      @proof_of_employment_apply = current_user.proof_of_employment_applies.build
      set_8_predefined_field
    end

    def create
      @proof_of_employment_apply = current_user.proof_of_employment_applies.build(proof_of_employment_apply_params)
      set_8_predefined_field
      respond_to do |format|
        if @proof_of_employment_apply.save
          format.html { redirect_to person_proof_of_employments_path, notice: t('.success') }
        else
          format.html { render :new }
        end
      end
    end

    def destroy
      @proof_of_employment_apply.destroy
      respond_to do |format|
        format.html { redirect_to person_proof_of_employments_path, notice: t('.success') }
        format.json { head :no_content }
      end
    end

    def start_approve
      if @proof_of_employment_apply.begin_task_id.present? || @proof_of_employment_apply.backend_in_processing
        redirect_to person_proof_of_employments_path, notice: t('.repeated_approve_request')
        return
      end

      attachment_list = @proof_of_employment_apply.attachments.collect do |attachment|
        { file_name: attachment.filename.to_s,
          url: rails_blob_url(attachment) }
      end

      bizData = {
        sender: 'Cybros',
        cybros_form_id: "proof_of_employment_apply_id_#{@proof_of_employment_apply.id}",
        applicant_name: @proof_of_employment_apply.employee_name,
        applicant_code: @proof_of_employment_apply.clerk_code,
        application_type: 'personal',
        application_class: 'zzzm',
        work_company_name: @proof_of_employment_apply.belong_company_name,
        work_company_code: @proof_of_employment_apply.belong_company_code, # 申请人归属公司编码
        work_dept_name: @proof_of_employment_apply.belong_department_name,
        work_dept_code: @proof_of_employment_apply.belong_department_code, # 申请人所属部门编码
        lc_company_name: @proof_of_employment_apply.contract_belong_company,
        lc_company_code: @proof_of_employment_apply.contract_belong_company_code, # 申请人所属部门编码
        stamp_location_name: Personal::ProofOfEmploymentApply.sh_stamp_place.key(@proof_of_employment_apply.stamp_to_place),
        stamp_location_code: @proof_of_employment_apply.stamp_to_place,
        application_reason: @proof_of_employment_apply.stamp_comment,
        attachment_list: attachment_list,
        created_at: @proof_of_employment_apply.created_at,
        updated_at: @proof_of_employment_apply.updated_at
      }

      @proof_of_employment_apply.update_columns(backend_in_processing: true)
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
        json: { processName: 'OfficialSealUsageApplication', taskId: '', action: '', comments: '', step: 'Begin',
        userCode: current_user.clerk_code, bizData: bizData.to_json })
      Rails.logger.debug "OfficialSealUsage ProofOfEmploymentApply handler response: #{response}"
      result = JSON.parse(response.body.to_s)
      @proof_of_employment_apply.update_columns(backend_in_processing: false)

      if result['isSuccess'] == '1'
        @proof_of_employment_apply.update(begin_task_id: result['BeginTaskId'])
        redirect_to person_proof_of_employments_path, notice: t('.success')
      else
        @proof_of_employment_apply.update(bpm_message: result['message'])
        redirect_to person_proof_of_employments_path, notice: t('.failed', message: result['message'])
      end
    end

    def view_attachment
      @attachment = @proof_of_employment_apply.attachments.find_by!(id: params[:attachment_id])
    end

    private

      def set_8_predefined_field
        @proof_of_employment_apply.employee_name = current_user.chinese_name
        @proof_of_employment_apply.clerk_code = current_user.clerk_code
        current_user_department = current_user.departments.first
        if current_user_department.present?
          @proof_of_employment_apply.belong_company_name = current_user_department.company_name
          @proof_of_employment_apply.belong_company_code = current_user_department.company_code
          @proof_of_employment_apply.belong_department_name = current_user_department.name
          @proof_of_employment_apply.belong_department_code = current_user_department.dept_code
          @proof_of_employment_apply.contract_belong_company = Nc::PsndocCtrt.contract_belong_company(current_user.clerk_code)
          @proof_of_employment_apply.contract_belong_company_code = Bi::OrgShortName.org_code_by_long_name.fetch(@proof_of_employment_apply.contract_belong_company, current_user_department.company_code)
        end
      end

      def set_proof_of_employment_apply
        @proof_of_employment_apply = policy_scope(Personal::ProofOfEmploymentApply).find(params[:id])
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
        { text: t('layouts.sidebar.person.proof_of_employment'),
          link: person_proof_of_employments_path }]
      end

      def proof_of_employment_apply_params
        params.require(:personal_proof_of_employment_apply)
          .permit(:employee_name, :clerk_code,
            :belong_company_name, :belong_company_code,
            :belong_department_name, :belong_department_code,
            :contract_belong_company, :contract_belong_company_code,
            :stamp_to_place, :stamp_comment, attachments: [])
      end
  end
end
