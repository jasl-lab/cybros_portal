# frozen_string_literal: true

namespace :we_market do
  resource :posting, only: %i[show]
  resource :mine, only: %i[show]
end
