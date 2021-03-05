# frozen_string_literal: true

json.userinfo @wechat_user, partial: 'userinfo', as: :userinfo
json.hasBindMobile @wechat_user.mobile.present?
json.identities @identities
