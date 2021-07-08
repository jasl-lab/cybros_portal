# frozen_string_literal: true

class GenerateRoleAllWorker
  include Sidekiq::Worker

  def perform
    Role.sync_all
    Role.first.update_columns(in_generating: false)
  end
end
