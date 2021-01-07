# frozen_string_literal: true

class Person::NameCardBlackTitlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @name_card_black_titles = NameCardBlackTitle.all
    @new_card_black_title = NameCardBlackTitle.new
  end

  def create
    @new_card_black_title = NameCardBlackTitle.new(name_card_black_title_params)

    if @new_card_black_title.save
      redirect_to person_name_card_black_titles_path, notice: t('.created')
    else
      prepare_meta_tags title: t('.title')
      @name_card_black_titles = NameCardBlackTitle.all
      render :index
    end
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'person'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.person.header'),
        link: person_root_path },
      { text: t('layouts.sidebar.person.name_card_black_title'),
        link: person_name_card_black_titles_path }]
    end

  private

    def name_card_black_title_params
      params.fetch(:name_card_black_title, {}).permit(:original_title, :required_title)
    end
end
