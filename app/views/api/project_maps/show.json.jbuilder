# frozen_string_literal: true

json.array! @valid_map_points do |point|
  json.id point[:project_code].split('').collect { |item| item.match?(/^\d$/) ? item : item.getbyte(0).to_s }.reduce(:+).to_i
  json.code point[:project_code]
  json.title point[:title]
  json.lat point[:lat]
  json.lng point[:lng]
  json.frameName point[:project_frame_name]
  json.traceState point[:trace_state]
  json.scaleArea point[:scale_area]
  json.province point[:province]
  json.city point[:city]
  json.businessTypeDeptnames point[:business_type_deptnames].collect { |item| item.join(' | ') }
end
