require File.dirname(__FILE__) + '/../test_helper'
require 'application'

class ApplicationControllerTest < Test::Unit::TestCase
  def setup
    @controller = nil
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # test auth for all public methods in all controllers
  Dir.new( File.join( File.dirname(__FILE__), '/../../app/controllers')).each do | entry |
    if match = entry.match(/(([a-z_0-]+)_controller)\.rb/)
      controller = match[2]
      next if ['feedback','user'].member?( controller )
      require( match[1] )
      klass = "#{match[2].capitalize}Controller".constantize
      klass.action_methods.each do | method |
        next if controller == "submission" && method == "index"
        define_method "test_auth_#{controller}_#{method}" do
          @controller = klass.new
          get method
          assert_response 401
        end

      end
    end
  end

end
