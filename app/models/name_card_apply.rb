class NameCardApply < ApplicationRecord
  belongs_to :user
  validates :department_name, :title, :english_name, :en_department_name,
    :en_title, :mobile, :print_out_box_number, presence: true
end
