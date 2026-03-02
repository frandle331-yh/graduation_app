require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    get dashboard_url
    assert_response :success
  end
  test "should get show" do
    get dashboard_url
    assert_response :success
  end
end
