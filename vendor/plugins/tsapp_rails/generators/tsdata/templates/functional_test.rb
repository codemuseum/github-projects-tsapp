require 'test_helper'

class <%= class_name %>ControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= class_name.downcase %>)
  end
end
