require 'authlogic'

class UserSession < Authlogic::Session::Base
  def for_cookie
    {
      key: cookie_key,
      value: generate_cookie_for_saving[:value]
    }
  end
end