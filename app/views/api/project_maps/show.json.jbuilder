# frozen_string_literal: true

json.points @valid_map_points do |point|
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
