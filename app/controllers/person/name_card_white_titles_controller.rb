class Person::NameCardWhiteTitlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @name_card_white_titles = NameCardWhiteTitle.all
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "person"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.person.header"),
      link: person_root_path },
    { text: t("layouts.sidebar.person.name_card_white_title"),
      link: person_name_card_white_titles_path }]
  end
end
