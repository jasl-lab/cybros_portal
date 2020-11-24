# frozen_string_literal: true

module AllocationBaseHelper
  def current_status(nc_record)
    if nc_record.end_date.present?
      'archived'
    elsif nc_record.start_date.present?
      'confirmed'
    elsif nc_record.version.present?
      'submitted'
    else
      'editing'
    end
  end
end
