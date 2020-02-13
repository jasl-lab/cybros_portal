# frozen_string_literal: true

module StampPlace
  extend ActiveSupport::Concern

  class_methods do
    def sh_stamp_place
      {
        兆丰: 'zf',
        科汇: 'kh',
        杨浦: 'yp'
      }
    end
  end
end
