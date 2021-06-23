# frozen_string_literal: true

namespace :role do
  desc 'Filling HR role and CW roles'
  task all: [:clean_auto_generated_role_access, :auto_hr_access_role, :create_hr_role_access, :auto_cw_access_role, :create_cw_role_access]

  desc 'Clean auto generated role access'
  task clean_auto_generated_role_access: :environment do
    Role.clean_auto_generated_role_access
  end

  desc 'Filling HR access code by logic'
  task auto_hr_access_role: :environment do
    Role.auto_hr_access_role
  end

  desc 'Create role for having HR access code users'
  task create_hr_role_access: :environment do
    Role.create_hr_role_access
  end

  desc 'Filling CW access code by logic'
  task auto_cw_access_role: :environment do
    Role.auto_cw_access_role
  end

  desc 'Create role for having CW access code users'
  task create_cw_role_access: :environment do
    Role.create_cw_role_access
  end
end
