require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email_address: "test@example.com")
    sign_in_as(@user)
  end

  test "should get index when authenticated" do
    get root_url
    assert_response :success
  end

  test "should redirect to login when not authenticated" do
    delete session_url # Sign out
    get root_url
    assert_redirected_to new_session_path
  end
end
