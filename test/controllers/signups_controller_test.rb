require "test_helper"

class SignupsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_signups_url
    assert_response :success
  end

  test "should create user with valid params" do
    assert_difference "User.count", 1 do
      post signups_url, params: {
        email_address: "newuser@example.com",
        name: "New User"
      }
    end

    user = User.last
    assert_equal "newuser@example.com", user.email_address
    assert_equal "New User", user.name
    assert_redirected_to verify_session_path
  end

  test "should create authentication token on signup" do
    assert_difference "AuthenticationToken.count", 1 do
      post signups_url, params: {
        email_address: "newuser@example.com",
        name: "New User"
      }
    end

    token = AuthenticationToken.last
    assert_equal User.last, token.user
    assert_not_nil token.token
    assert_not_nil token.code
  end

  test "should send welcome email on signup" do
    assert_enqueued_emails 1 do
      post signups_url, params: {
        email_address: "newuser@example.com",
        name: "New User"
      }
    end
  end

  test "should not create user with invalid email" do
    assert_no_difference "User.count" do
      post signups_url, params: {
        email_address: "invalid",
        name: "New User"
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with missing name" do
    assert_no_difference "User.count" do
      post signups_url, params: {
        email_address: "newuser@example.com",
        name: ""
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with duplicate email" do
    User.create!(email_address: "existing@example.com", name: "Existing User")

    assert_no_difference "User.count" do
      post signups_url, params: {
        email_address: "existing@example.com",
        name: "Another User"
      }
    end

    assert_response :unprocessable_entity
  end


  test "signup does not accept password parameters" do
    post signups_url, params: {
      email_address: "newuser@example.com",
      name: "New User",
      password: "shouldbeignored",
      password_confirmation: "shouldbeignored"
    }

    user = User.last
    assert_equal "newuser@example.com", user.email_address
    assert_redirected_to verify_session_path
  end
end
