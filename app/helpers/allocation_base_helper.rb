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

  def cost_split_allocation_base_possible_next_form_actions(status)
    case status
    when 'archived'
      []
    when 'confirmed'
      ['version_up']
    when 'submitted'
      ['confirm', 'reject']
    when 'editing'
      ['save', 'submit']
    end
  end
end
