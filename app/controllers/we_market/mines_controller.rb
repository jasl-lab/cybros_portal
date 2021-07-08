# frozen_string_literal: true

module WeMarket
  class MinesController < WeMarket::ApplicationController
    def show
      prepare_meta_tags title: t('.title')
    end
  end
end
