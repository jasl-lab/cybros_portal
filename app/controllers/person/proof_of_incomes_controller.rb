# frozen_string_literal: true

module Person
  class ProofOfIncomesController < ApplicationController
    include BreadcrumbsHelper
    before_action :authenticate_user!
    before_action :set_page_layout_data, if: -> { request.format.html? }
    before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
    before_action :set_proof_of_income_apply, only: %i[show destroy start_approve view_attachment]

    def index
      respond_to do |format|
        format.html do
          prepare_meta_tags title: t('.title')
        end
        format.json do
          proof_of_income_applies = policy_scope(Personal::ProofOfIncomeApply).with_attached_attachments.all
          render json: Personal::ProofOfIncomeDatatable.new(params,
            proof_of_income_applies: proof_of_income_applies,
            view_context: view_context)
        end
      end
    end

    def show
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
        json: { processName: '', incident: '', taskId: @proof_of_income_apply.begin_task_id })
      Rails.logger.debug "name cards apply history response: #{response}"
      @result = JSON.parse(response.body.to_s)
      render 'shared/show_task_detail'
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.proof_of_incomes.index.actions.new'), new_person_proof_of_income_path)
      @proof_of_income_apply = current_user.proof_of_income_applies.build
      @proof_of_income_apply.employee_name = current_user.chinese_name
      @proof_of_income_apply.clerk_code = current_user.clerk_code
      current_user_department = current_user.departments.first
      if current_user_department.present?
        @proof_of_income_apply.belong_company_name = current_user_department.company_name
        @proof_of_income_apply.belong_company_code = current_user_department.company_code
        @proof_of_income_apply.belong_department_name = current_user_department.name
        @proof_of_income_apply.belong_department_code = current_user_department.dept_code
        @proof_of_income_apply.contract_belong_company = UltDb::Query.contract_belong_company(current_user.clerk_code)
        @proof_of_income_apply.contract_belong_company_code = Bi::OrgShortName.org_code_by_long_name.fetch(@proof_of_income_apply.contract_belong_company, current_user_department.company_code)
      end
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

    def destroy
      @proof_of_income_apply.destroy
      respond_to do |format|
        format.html { redirect_to person_proof_of_incomes_path, notice: t('.success') }
        format.json { head :no_content }
      end
    end

    def start_approve
      if @proof_of_income_apply.begin_task_id.present? || @proof_of_income_apply.backend_in_processing
        redirect_to person_proof_of_incomes_path, notice: t('.repeated_approve_request')
        return
      end

      attachment_list = @proof_of_income_apply.attachments.collect do |attachment|
        { file_name: attachment.filename.to_s,
          url: rails_blob_url(attachment) }
      end

      bizData = {
        sender: 'Cybros',
        cybros_form_id: "proof_of_income_apply_id_#{@proof_of_income_apply.id}",
        applicant_name: @proof_of_income_apply.employee_name,
        applicant_code: @proof_of_income_apply.clerk_code,
        application_type: 'personal',
        application_class: 'srzm',
        work_company_name: @proof_of_income_apply.belong_company_name,
        work_company_code: @proof_of_income_apply.belong_company_code, # 申请人归属公司编码
        work_dept_name: @proof_of_income_apply.belong_department_name,
        work_dept_code: @proof_of_income_apply.belong_department_code, # 申请人所属部门编码
        lc_company_name: @proof_of_income_apply.contract_belong_company,
        lc_company_code: @proof_of_income_apply.contract_belong_company_code, # 申请人所属部门编码
        stamp_location_name: Personal::ProofOfIncomeApply.sh_stamp_place.key(@proof_of_income_apply.stamp_to_place),
        stamp_location_code: @proof_of_income_apply.stamp_to_place,
        application_reason: @proof_of_income_apply.stamp_comment,
        attachment_list: attachment_list,
        created_at: @proof_of_income_apply.created_at,
        updated_at: @proof_of_income_apply.updated_at
      }

      @proof_of_income_apply.update_columns(backend_in_processing: true)
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
        json: { processName: 'OfficialSealUsageApplication', taskId: '', action: '', comments: '', step: 'Begin',
        userCode: current_user.clerk_code, bizData: bizData.to_json })
      Rails.logger.debug "OfficialSealUsage ProofOfIncomeApply handler response: #{response}"
      result = JSON.parse(response.body.to_s)
      @proof_of_income_apply.update_columns(backend_in_processing: false)

      if result['isSuccess'] == '1'
        @proof_of_income_apply.update(begin_task_id: result['BeginTaskId'])
        redirect_to person_proof_of_incomes_path, notice: t('.success')
      else
        @proof_of_income_apply.update(bpm_message: result['message'])
        redirect_to person_proof_of_incomes_path, notice: t('.failed', message: result['message'])
      end
    end

    def view_attachment
      @attachment = @proof_of_income_apply.attachments.find_by!(id: params[:attachment_id])
    end

    private

      def set_proof_of_income_apply
        @proof_of_income_apply = policy_scope(Personal::ProofOfIncomeApply).find(params[:id])
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
        { text: t('layouts.sidebar.person.proof_of_income'),
          link: person_proof_of_incomes_path }]
      end

      def proof_of_income_apply_params
        params.require(:personal_proof_of_income_apply)
          .permit(:employee_name, :clerk_code,
            :belong_company_name, :belong_company_code,
            :belong_department_name, :belong_department_code,
            :contract_belong_company, :contract_belong_company_code,
            :stamp_to_place, :stamp_comment, attachments: [])
      end
  end
end
