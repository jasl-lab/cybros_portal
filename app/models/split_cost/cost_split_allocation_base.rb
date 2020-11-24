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
  end
end
