# frozen_string_literal: true

class NameCardApply < ApplicationRecord
  belongs_to :user

  auto_strip_attributes :title, :english_name

  validates :chinese_name, :email, :company_name, :department_name, :title,
    :office_address, :office_level, :mobile, :print_out_box_number, presence: true
  validates :thickness, :back_color, presence: true, on: :create
  validate :title_exclude_from_black_title, if: Proc.new { Current.user.present? }
  validates :mobile, length: { is: 11 }

  def self.thickness_list
    ['400g',
     '270g']
  end

  def self.back_color_list
    ['四色（每色25张，100张/盒）',
     '单色：红（100张/盒）',
     '单色：黄（100张/盒）',
     '单色：深蓝（100张/盒）',
     '单色：灰（100张/盒）',
     '双色：红黄（100张/盒）',
     '双色：红蓝（100张/盒）',
     '双色：红灰（100张/盒）',
     '双色：黄蓝（100张/盒）',
     '双色：黄灰（100张/盒）',
     '双色：蓝灰（100张/盒）']
  end

  private

    def title_exclude_from_black_title
      if title.in?(NameCardBlackTitle.where(original_title: Current.user.position_title).pluck(:required_title))
        errors.add(:title, :title_is_blocked)
      end
    end
end
