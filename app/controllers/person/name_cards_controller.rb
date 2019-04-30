class Person::NameCardsController < ApplicationController
  include BreadcrumbsHelper
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index new], if: -> { request.format.html? }
  before_action :set_name_card_apply, only: %i[destroy start_approve]

  def index
    prepare_meta_tags title: t(".title")
    @name_card_applies = policy_scope(NameCardApply)
  end

  def new
    prepare_meta_tags title: t(".form_title")
    add_to_breadcrumbs(t("person.name_cards.index.actions.new"), new_person_name_card_path)
    @name_card_apply = current_user.name_card_applies.build
    @name_card_apply.title= current_user.position_title
  end

  def create
    @name_card_apply = current_user.name_card_applies.build(name_card_apply_params)
    respond_to do |format|
      if @name_card_apply.save
        format.html { redirect_to person_name_cards_path, notice: t('.success') }
      else
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

  def start_approve
    respond_to do |format|
      format.html { redirect_to person_name_cards_path, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  protected

  def name_card_apply_params
    params.require(:name_card_apply).permit(:department_name, :title, :english_name, :en_department_name, :en_title, :mobile, :phone_ext, :fax_no, :office_level, :print_out_box_number)
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
end
