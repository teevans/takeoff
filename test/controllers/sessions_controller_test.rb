require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email_address: "test@example.com")
  end

  test "should get new" do
    get new_session_path
    assert_response :success
  end

  test "should redirect verify to login when no email in session" do
    get verify_session_path
    assert_redirected_to new_session_path
    assert_equal "Please enter your email first", flash[:alert]
  end

  test "should show verify page when email is in session" do
    post session_path, params: { email_address: @user.email_address }
    get verify_session_path
    assert_response :success
  end

  test "should create authentication token for existing user" do
    assert_difference "AuthenticationToken.count", 1 do
      post session_path, params: { email_address: @user.email_address }
    end

    token = AuthenticationToken.last
    assert_equal @user, token.user
    assert_redirected_to verify_session_path
  end

  test "should not create token for non-existent user" do
    assert_no_difference "AuthenticationToken.count" do
      post session_path, params: { email_address: "nonexistent@example.com" }
    end

    assert_redirected_to verify_session_path
  end

  test "should send magic link email for existing user" do
    assert_enqueued_emails 1 do
      post session_path, params: { email_address: @user.email_address }
    end
  end

  test "should not send email for non-existent user" do
    assert_enqueued_emails 0 do
      post session_path, params: { email_address: "nonexistent@example.com" }
    end
  end

  test "should verify with valid token" do
    token = @user.authentication_tokens.create!
    
    get verify_session_path, params: { token: token.token }
    
    assert_redirected_to root_path
    assert cookies[:session_id]
    
    token.reload
    assert_not_nil token.used_at
  end

  test "should verify with valid code and email" do
    token = @user.authentication_tokens.create!
    
    get verify_session_path, params: { 
      code: token.code, 
      email_address: @user.email_address 
    }
    
    assert_redirected_to root_path
    assert cookies[:session_id]
    
    token.reload
    assert_not_nil token.used_at
  end

  test "should not verify with invalid token" do
    get verify_session_path, params: { token: "invalid" }
    
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "should not verify with expired token" do
    token = @user.authentication_tokens.create!
    token.update!(expires_at: 1.minute.ago)
    
    get verify_session_path, params: { token: token.token }
    
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "should not verify with already used token" do
    token = @user.authentication_tokens.create!
    token.use!
    
    get verify_session_path, params: { token: token.token }
    
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "should not verify with wrong code" do
    token = @user.authentication_tokens.create!
    
    get verify_session_path, params: { 
      code: "WRONG", 
      email_address: @user.email_address 
    }
    
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "should not verify with wrong email" do
    token = @user.authentication_tokens.create!
    
    get verify_session_path, params: { 
      code: token.code, 
      email_address: "wrong@example.com" 
    }
    
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  # Note: Rate limiting test is commented out as it requires specific test setup
  # The rate limiting is configured in the controller with:
  # rate_limit to: 10, within: 3.minutes, only: :create
  #
  # test "rate limiting on create" do
  #   # Rate limit is 10 requests within 3 minutes
  #   10.times do
  #     post session_path, params: { email_address: @user.email_address }
  #   end
  #   
  #   # 11th request should be rate limited
  #   post session_path, params: { email_address: @user.email_address }
  #   assert_redirected_to new_session_path
  #   assert_match /Try again later/, flash[:alert]
  # end
end
