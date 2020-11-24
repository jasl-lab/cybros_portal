# frozen_string_literal: true

module AllocationBaseHelper
  def current_status(nc_record)
    status = if nc_record.end_date.present?
      'archived'
    elsif nc_record.start_date.present?
      'confirmed'
    elsif nc_record.version.present?
      'submitted'
    else
      'editing'
    end
    I18n.t("activerecord.attributes.split_cost/cost_splite_allocation_base.status.#{status}")
  end
end
