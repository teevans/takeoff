require "test_helper"

class AuthenticationTokenTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(name: "Test User", email_address: "test@example.com")
    @token = @user.authentication_tokens.create!
  end

  test "generates token and code on creation" do
    assert_not_nil @token.token
    assert_not_nil @token.code
    assert_equal 6, @token.code.length
    assert_match /^[A-Z0-9]{6}$/, @token.code
  end

  test "sets expiration time on creation" do
    assert_not_nil @token.expires_at
    assert_in_delta 15.minutes.from_now, @token.expires_at, 1.second
  end

  test "token is unique" do
    token2 = @user.authentication_tokens.create!
    assert_not_equal @token.token, token2.token
  end

  test "code is unique among active tokens" do
    token2 = @user.authentication_tokens.create!
    assert_not_equal @token.code, token2.code
  end

  test "finds valid token" do
    found_token = AuthenticationToken.find_by_valid_token(@token.token)
    assert_equal @token, found_token
  end

  test "does not find expired token" do
    @token.update!(expires_at: 1.minute.ago)
    found_token = AuthenticationToken.find_by_valid_token(@token.token)
    assert_nil found_token
  end

  test "does not find used token" do
    @token.use!
    found_token = AuthenticationToken.find_by_valid_token(@token.token)
    assert_nil found_token
  end

  test "finds valid code for user" do
    found_token = AuthenticationToken.find_by_valid_code(@token.code, @user.id)
    assert_equal @token, found_token
  end

  test "does not find code for different user" do
    other_user = User.create!(name: "Other User", email_address: "other@example.com")
    found_token = AuthenticationToken.find_by_valid_code(@token.code, other_user.id)
    assert_nil found_token
  end

  test "use! marks token as used" do
    assert_nil @token.used_at
    @token.use!
    assert_not_nil @token.used_at
    assert_in_delta Time.current, @token.used_at, 1.second
  end

  test "used? returns correct status" do
    assert_not @token.used?
    @token.use!
    assert @token.used?
  end

  test "expired? returns correct status" do
    assert_not @token.expired?
    @token.update!(expires_at: 1.minute.ago)
    assert @token.expired?
  end

  test "is_valid? returns true for unused and unexpired token" do
    assert @token.is_valid?
  end

  test "is_valid? returns false for used token" do
    @token.use!
    assert_not @token.is_valid?
  end

  test "is_valid? returns false for expired token" do
    @token.update!(expires_at: 1.minute.ago)
    assert_not @token.is_valid?
  end

  test "active scope returns only unused and unexpired tokens" do
    active_token = @user.authentication_tokens.create!
    used_token = @user.authentication_tokens.create!
    used_token.use!
    expired_token = @user.authentication_tokens.create!
    expired_token.update!(expires_at: 1.minute.ago)

    active_tokens = AuthenticationToken.active
    assert_includes active_tokens, @token
    assert_includes active_tokens, active_token
    assert_not_includes active_tokens, used_token
    assert_not_includes active_tokens, expired_token
  end
end