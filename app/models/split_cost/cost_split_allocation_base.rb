# frozen_string_literal: true

module SplitCost
  class CostSplitAllocationBase < ApplicationRecord
    CALC_BASE_NAMES = %w[
      创意板块平均总人数
      创意板块上海区域人数
      施工图人数
      方案人数
      建筑人数
      结构人数
      机电人数
      外审事务所报价
      创意板块及新业务
      创意板块及新业务（上海区域）
      创意板块及新业务（上海区域2020年1月年会人数）
      创意板块及新业务（2020年12月31日人数）
      上年平均人数
    ]

    # 上海天华、AICO建筑、上海室内、上海规划、天华景观、虹核审图、EID SH、AICO室内、易术家
    SHANGHAI_BASE_COMPANY_CODE = %w[
      000101
      000151
      000113
      000112
      000114
      000117
      000126
      000124
      000122
    ]

    # 上海天华、AICO建筑、上海室内、上海规划、天华景观、虹核审图、EID SH、AICO室内、天华节能、易术家、易湃工程、环境中心、易衡光伏科技
    SHANGHAI_BASE_NEW_COMPANY_CODE = %w[
      000101
      000151
      000113
      000112
      000114
      000117
      000126
      000124
      000103
      000122
      000150
      000149
      000130
    ]

    def self.all_pmonths
      order(pmonth: :desc).distinct.pluck(:pmonth)
    end

    def self.all_company_shortnames_with_code
      return @all_company_shortnames_with_code if @all_company_shortnames_with_code.present?

      all_company_codes = all.distinct.pluck(:company_code)

      @all_company_shortnames_with_code = all_company_codes.collect do |company_code|
        [ Bi::OrgShortName.company_short_names_by_orgcode[company_code], company_code ]
      end
    end

    def self.head_count_at(base_name, company_codes, start_date)
      company_codes = Array(company_codes)
      SplitCost::CostSplitAllocationBase
        .where(base_name: base_name, company_code: company_codes)
        .where(pmonth: start_date.to_s(:short_month)).sum(:head_count)
    end
  end
end
