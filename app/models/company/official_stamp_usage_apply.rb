# frozen_string_literal: true

module Company
  class OfficialStampUsageApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
    include Personal::CommonValidate
    validates :application_class, presence: true
    validate :application_subclasses_not_empty

    serialize :application_subclasses, Array

    def self.usage_list
      {
        人力资源部: %w[录用退工手续办理 居住证手续办理 社保公积金手续办理 员工落户手续办理 人事类申报（工资总额、社保基数、公积金基数等） 开具介绍信 委托书 社保审查资料 劳动能力鉴定资料 职称申报 注册报考相关资料 其他],
        总经办: %w[对外发函 以公司名义签订的备忘录（主营业务类除外） 股东会文件 工商登记相关 资质申请相关 高新材料的申报 知识产权的申报 其他],
        法务: %w[诉讼材料],
        学院: %w[培训证书、通知、说明等],
        创意板块财务: %w[财务报表 向税务、银行、工商等相关单位提供财务资料 函证、企业间对账确认 经营财务对子公司的发文 其他],
        新业务板块财务: %w[财务报表 向税务、银行、工商等相关单位提供财务资料 函证、企业间对账确认 经营财务对子公司的发文 其他],
        综合管理部: %w[物业合同、房屋租赁合同等 以公司名义开具的相关证明材料 其他],
        信息部: %w[电信、移动类业务情况说明 物业相关申请书 其他],
      }
    end

    def self.usage_code_map
      {
        人力资源部: 'cy_hr',
        总经办: 'gm_office',
        法务: 'legal',
        学院: 'academy',
        创意板块财务: 'cy_fin',
        新业务板块财务: 'xyw_fin',
        综合管理部: 'cmpmgmt',
        信息部: 'it',
      }
    end

    private

      def application_subclasses_not_empty
        return true if application_subclasses.reject(&:blank?).present?

        errors.add(:application_subclasses, :must_present)
      end
  end
end
