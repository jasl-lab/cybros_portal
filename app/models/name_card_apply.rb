class NameCardApply < ApplicationRecord
  belongs_to :user

  auto_strip_attributes :title, :english_name

  validates :chinese_name, :email, :company_name, :department_name, :title,
    :office_address, :office_level, :mobile, :print_out_box_number, presence: true
  validate :title_exclude_from_black_title, if: Proc.new { Current.user.present? }
  validates :mobile, length: { is: 11 }

  private

  def title_exclude_from_black_title
    if title.in?(NameCardBlackTitle.where(original_title: Current.user.position_title).pluck(:required_title))
      errors.add(:title, :title_is_blocked)
    end
  end
end
