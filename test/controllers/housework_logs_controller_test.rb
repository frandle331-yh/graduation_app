require "test_helper"

class HouseworkLogsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in users(:one)
  end
  
  test "should get index" do
    get housework_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_housework_log_url
    assert_response :success
  end

  test "should get create" do
    get housework_logs_url
    assert_response :success
  end
end
