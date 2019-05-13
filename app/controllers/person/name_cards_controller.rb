class Person::NameCardsController < ApplicationController
  include BreadcrumbsHelper
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index new show], if: -> { request.format.html? }
  before_action :set_name_card_apply, only: %i[destroy start_approve show]

  def index
    prepare_meta_tags title: t(".title")
    @name_card_applies = policy_scope(NameCardApply)
  end

  def new
    prepare_meta_tags title: t(".form_title")
    add_to_breadcrumbs(t("person.name_cards.index.actions.new"), new_person_name_card_path)
    @name_card_apply = current_user.name_card_applies.build
    @name_card_apply.title = current_user.position_title
    @name_card_title_fill_hint = name_card_title_hint(@name_card_apply.title)
  end

  def create
    @name_card_apply = current_user.name_card_applies.build(name_card_apply_params)
    respond_to do |format|
      if @name_card_apply.save
        format.html { redirect_to person_name_cards_path, notice: t('.success') }
      else
        @name_card_title_fill_hint = name_card_title_hint(@name_card_apply.title)
        format.html { render :new }
      end
    end
  end

  def destroy
    @name_card_apply.destroy
    respond_to do |format|
      format.html { redirect_to person_name_cards_path, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  def show
    response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_history],
      :json => { processName: '', incident: '', taskId: @name_card_apply.begin_task_id })
    Rails.logger.debug "name cards apply history response: #{response}"
    @result = JSON.parse(response.body.to_s)
  end

  def start_approve
    bizData = {
      sender: 'Cybros',
      name_card_id: @name_card_apply.id,
      applicant_name: current_user.chinese_name,
      applicant_code: current_user.clerk_code,
      english_name: @name_card_apply.english_name,
      en_department_name: @name_card_apply.en_department_name,
      department_name: @name_card_apply.department_name,
      title: @name_card_apply.title,
      en_title: @name_card_apply.en_title,
      isWhitelisted: @name_card_apply.title.in?(NameCardWhiteTitle.where(original_title: current_user.position_title).pluck(:required_title)),
      phone_ext: @name_card_apply.phone_ext,
      fax_no: @name_card_apply.fax_no,
      mobile: @name_card_apply.mobile,
      print_out_box_number: @name_card_apply.print_out_box_number,
      receive_address: '秘书转交',
      created_at: @name_card_apply.created_at,
      updated_at: @name_card_apply.updated_at
    }
    response = HTTP.post(Rails.application.credentials[Rails.env.to_sym][:bpm_process_restapi_handler],
      :json => { processName: 'NameCardApplication', taskId: "", action: "", comments: "", step: "Begin",
      userCode: current_user.clerk_code, bizData: bizData.to_json })
    Rails.logger.debug "name cards apply handler response: #{response}"
    result = JSON.parse(response.body.to_s)
    if result['isSuccess'] == '1'
      @name_card_apply.update(begin_task_id: result['BeginTaskId'])
      redirect_to person_name_cards_path, notice: t('.success')
    else
      @name_card_apply.update(bpm_message: result['message'])
      redirect_to person_name_cards_path, notice: t('.failed', message: result['message'])
    end
  end

  protected

  def name_card_apply_params
    params.require(:name_card_apply).permit(:department_name, :title, :english_name,
      :en_department_name, :en_title, :mobile, :phone_ext, :fax_no, :print_out_box_number)
  end

  def set_page_layout_data
    @_sidebar_name = "person"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.person.header"),
      link: person_root_path },
    { text: t("layouts.sidebar.person.name_card"),
      link: person_name_cards_path }]
  end

  private

  def set_name_card_apply
    @name_card_apply = policy_scope(NameCardApply).find(params[:id])
  end

  def name_card_title_hint(name_card_title)
    name_card_white_titles = NameCardWhiteTitle.where(original_title: @name_card_apply.title).pluck(:required_title)
    name_card_black_titles = NameCardBlackTitle.where(original_title: @name_card_apply.title).pluck(:required_title)
    return if name_card_white_titles.blank? && name_card_black_titles.blank?
    t(".name_card_title_fill_hint", white_titles: name_card_white_titles.to_sentence, black_titles: name_card_black_titles.to_sentence)
  end
end
