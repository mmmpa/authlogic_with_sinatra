require 'authlogic'

# ActiveRecord::RecordInvalidと同じ挙動にする。
module Authlogic
  module Session
    module Existence
      class SessionInvalidError < ::StandardError # :nodoc:
        def initialize(session)
          super
          @record = session
        end

        def record
          @record
        end
      end
    end
  end
end

class UserSession < Authlogic::Session::Base
  class << self
    def in_session?
      !!find.try(:user)
    end
  end
end