# frozen_string_literal: true

if @tracestates.present?
  json.traceStates @tracestates
end
if @createddate_years.present?
  json.years @createddate_years
end
json.businessTypes @business_types do |business_type|
  json.value business_type[:value]
  json.projectTypes business_type[:project_types] do |project_type|
    json.value project_type[:value]
    json.serviceStages project_type[:service_stages]
  end
end
json.projectProcesses @project_processes
json.companies @companies
