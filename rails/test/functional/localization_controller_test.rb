require File.dirname(__FILE__) + '/../test_helper'
require 'localization_controller'

# Re-raise errors caught by the controller.
class LocalizationController; def rescue_action(e) raise e end; end

class LocalizationControllerTest < Test::Unit::TestCase

  def setup
    @controller = LocalizationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    authenticate_user( Account.select_single(:login_name=>'admin') )
  end

  def teardown
    POPE.deauth
  end

  def test_ui_message
    get :ui_message
    assert_response :success
  end

end
