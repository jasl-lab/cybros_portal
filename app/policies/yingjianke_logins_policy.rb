# frozen_string_literal: true

class YingjiankeLoginsPolicy < Struct.new(:user, :yingjianke_logins)
  def destroy?
    false
  end
end
