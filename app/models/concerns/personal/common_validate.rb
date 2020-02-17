# frozen_string_literal: true

module Personal
  module CommonValidate
    extend ActiveSupport::Concern

    included do
      validates :belong_company_name, :belong_company_code,
                :belong_department_name, :belong_department_code,
                :contract_belong_company, :contract_belong_company_code,
        presence: true
    end

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
end
