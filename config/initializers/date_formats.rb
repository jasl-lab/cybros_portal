# frozen_string_literal: true

Date::DATE_FORMATS[:month_and_year] = '%B %Y'
Time::DATE_FORMATS[:month_and_year] = '%B %Y'
Date::DATE_FORMATS[:short_month] = '%Y-%m'
Time::DATE_FORMATS[:short_month] = '%Y-%m'
Date::DATE_FORMATS[:short_date] = '%Y-%m-%d'
Time::DATE_FORMATS[:short_date] = '%Y-%m-%d'
Time::DATE_FORMATS[:db_short] = '%Y-%m-%d %H:%M'
Date::DATE_FORMATS[:nc_month] = '%Y%m'
Time::DATE_FORMATS[:nc_month] = '%Y%m'
