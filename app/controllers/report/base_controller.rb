# frozen_string_literal: true

class Report::BaseController < ApplicationController
  def cors_set_access_control_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET"
    headers["Access-Control-Request-Method"] = "*"
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, Authorization"
    headers["X-Frame-Options"] = "ALLOW-FROM http://172.16.1.159"
    headers["X-XSS-Protection"] = "0"
  end
end
