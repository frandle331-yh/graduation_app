require "test_helper"

class HouseworkLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get housework_logs_index_url
    assert_response :success
  end

  test "should get new" do
    get housework_logs_new_url
    assert_response :success
  end

  test "should get create" do
    get housework_logs_create_url
    assert_response :success
  end
end
