# frozen_string_literal: true

module API
  class OfficialSealUsagesController < ActionController::API
    def create
      official_seal_usage_id = params[:official_seal_usage_id]

      official_seal_usage_apply = if official_seal_usage_id.start_with? 'copy_of_business_license_apply_id_'
        Personal::CopyOfBusinessLicenseApply.find_by(id: official_seal_usage_id['copy_of_business_license_apply_id_'.length..])
      elsif official_seal_usage_id.start_with? 'proof_of_employment_apply_id_'
        Personal::ProofOfEmploymentApply.find_by(id: official_seal_usage_id['proof_of_employment_apply_id_'.length..])
      elsif official_seal_usage_id.start_with? 'proof_of_income_apply_id_'
        Personal::ProofOfIncomeApply.find_by(id: official_seal_usage_id['proof_of_income_apply_id_'.length..])
      elsif official_seal_usage_id.start_with? 'public_rental_housing_apply_id_'
        Personal::PublicRentalHousingApply.find_by(id: official_seal_usage_id['public_rental_housing_apply_id_'.length..])
      elsif official_seal_usage_id.start_with? 'official_stamp_usage_apply_id_'
        Company::OfficialStampUsageApply.find_by(id: official_seal_usage_id['official_stamp_usage_apply_id_'.length..])
      end

      return render json: { is_success: 404, error_message: '找不到记录' }, status: :not_found unless official_seal_usage_apply.present?

      official_seal_usage_apply.bpm_message = params[:message]
      if params[:approval_result].to_i == 1
        official_seal_usage_apply.status = '同意'
      else
        official_seal_usage_apply.status = '否决'
      end
      if official_seal_usage_apply.save
        render json: { is_success: true }, status: :ok
      else
        render json: { is_success: 400, error_message: official_seal_usage_apply.errors.full_messages, status: :bad_request }
      end
    end
  end
end
