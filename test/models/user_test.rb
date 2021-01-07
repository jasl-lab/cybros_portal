# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'User eric valid' do
    eric = users(:user_eric)
    assert eric.valid?
    assert_equal eric.roles.count, 2
  end
end
