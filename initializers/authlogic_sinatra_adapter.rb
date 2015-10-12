require 'authlogic'

module Authlogic
  module ControllerAdapters
    module SinatraAdapter
      class Adapter < AbstractAdapter
        #sinatraでsessionを使わない場合コメントアウトを外す
        #def session
        #  request.session
        #end
      end
    end
  end
end
