# frozen_string_literal: true

module Person
  class PublicRentalHousingsController < ApplicationController
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
          public_rental_housing_applies = policy_scope(Personal::PublicRentalHousingApply).with_attached_attachments.all
          render json: Personal::PublicRentalHousingDatatable.new(params,
            public_rental_housing_applies: public_rental_housing_applies,
            view_context: view_context)
        end
      end
    end

    def show
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
        json: { processName: '', incident: '', taskId: @public_rental_housing_apply.begin_task_id })
      Rails.logger.debug "name cards apply history response: #{response}"
      @result = JSON.parse(response.body.to_s)
      render file: '/shared/show_task_detail', locals: { show_task_detail_return_path: person_public_rental_housings_path }
    end

    def new
      prepare_meta_tags title: t('.form_title')
      add_to_breadcrumbs(t('person.public_rental_housings.index.actions.new'), new_person_public_rental_housing_path)
      @public_rental_housing_apply = current_user.public_rental_housing_applies.build
      @public_rental_housing_apply.employee_name = current_user.chinese_name
      @public_rental_housing_apply.clerk_code = current_user.clerk_code
      current_user_department = current_user.departments.first
      if current_user_department.present?
        @public_rental_housing_apply.belong_company_name = current_user_department.company_name
        @public_rental_housing_apply.belong_company_code = current_user_department.company_code
        @public_rental_housing_apply.belong_department_name = current_user_department.name
        @public_rental_housing_apply.belong_department_code = current_user_department.dept_code
        @public_rental_housing_apply.contract_belong_company = UltDb::Query.contract_belong_company(current_user.clerk_code)
        @public_rental_housing_apply.contract_belong_company_code = current_user_department.company_code
      end
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
      if @public_rental_housing_apply.begin_task_id.present? || @public_rental_housing_apply.backend_in_processing
        redirect_to person_public_rental_housings_path, notice: t('.repeated_approve_request')
        return
      end

      attachment_list = @public_rental_housing_apply.attachments.collect do |attachment|
        { file_name: attachment.filename.to_s,
          url: rails_blob_url(attachment) }
      end

      bizData = {
        sender: 'Cybros',
        cybros_form_id: "public_rental_housing_apply_id_#{@public_rental_housing_apply.id}",
        applicant_name: @public_rental_housing_apply.employee_name,
        applicant_code: @public_rental_housing_apply.clerk_code,
        application_type: 'personal',
        application_class: 'gzfsq',
        work_company_name: @public_rental_housing_apply.belong_company_name,
        work_company_code: @public_rental_housing_apply.belong_company_code, # 申请人归属公司编码
        work_dept_name: @public_rental_housing_apply.belong_department_name,
        work_dept_code: @public_rental_housing_apply.belong_department_code, # 申请人所属部门编码
        lc_company_name: @public_rental_housing_apply.contract_belong_company,
        lc_company_code: @public_rental_housing_apply.contract_belong_company_code, # 申请人所属部门编码
        stamp_location_name: Personal::PublicRentalHousingApply.sh_stamp_place.key(@public_rental_housing_apply.stamp_to_place),
        stamp_location_code: @public_rental_housing_apply.stamp_to_place,
        application_reason: @public_rental_housing_apply.stamp_comment,
        attachment_list: attachment_list,
        created_at: @public_rental_housing_apply.created_at,
        updated_at: @public_rental_housing_apply.updated_at
      }

      @public_rental_housing_apply.update_columns(backend_in_processing: true)
      response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
        json: { processName: 'OfficialSealUsageApplication', taskId: '', action: '', comments: '', step: 'Begin',
        userCode: current_user.clerk_code, bizData: bizData.to_json })
      Rails.logger.debug "OfficialSealUsage PublicRentalHousingApply handler response: #{response}"
      result = JSON.parse(response.body.to_s)
      @public_rental_housing_apply.update_columns(backend_in_processing: false)

      if result['isSuccess'] == '1'
        @public_rental_housing_apply.update(begin_task_id: result['BeginTaskId'])
        redirect_to person_public_rental_housings_path, notice: t('.success')
      else
        @public_rental_housing_apply.update(bpm_message: result['message'])
        redirect_to person_public_rental_housings_path, notice: t('.failed', message: result['message'])
      end
    end

    def view_attachment
      @attachment = @public_rental_housing_apply.attachments.find_by!(id: params[:attachment_id])
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
          .permit(:employee_name, :clerk_code,
            :belong_company_name, :belong_company_code,
            :belong_department_name, :belong_department_code,
            :contract_belong_company, :contract_belong_company_code,
            :stamp_to_place, :stamp_comment, attachments: [])
      end
  end
end
