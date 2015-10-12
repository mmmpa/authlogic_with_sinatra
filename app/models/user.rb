require 'active_record'
require 'authlogic'

class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.login_field = :login
    config.require_password_confirmation = false
  end
end