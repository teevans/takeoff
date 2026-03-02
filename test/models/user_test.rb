require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Test User", email_address: "test@example.com")
  end

  test "valid user" do
    assert @user.valid?
  end

  test "requires name" do
    @user.name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:name], "can't be blank"
  end

  test "requires email_address" do
    @user.email_address = ""
    assert_not @user.valid?
    assert_includes @user.errors[:email_address], "can't be blank"
  end

  test "validates email format" do
    invalid_emails = ["invalid", "invalid@", "@invalid.com", "invalid@.com"]
    invalid_emails.each do |email|
      @user.email_address = email
      assert_not @user.valid?, "#{email} should be invalid"
      assert_includes @user.errors[:email_address], "is invalid"
    end
  end

  test "accepts valid email formats" do
    valid_emails = ["user@example.com", "user.name@example.com", "user+tag@example.co.uk"]
    valid_emails.each do |email|
      @user.email_address = email
      assert @user.valid?, "#{email} should be valid"
    end
  end

  test "enforces unique email addresses" do
    @user.save!
    duplicate_user = User.new(name: "Another User", email_address: @user.email_address)
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "has already been taken"
  end

  test "email uniqueness is case insensitive" do
    @user.email_address = "test@example.com"
    @user.save!
    duplicate_user = User.new(name: "Another User", email_address: "TEST@EXAMPLE.COM")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "has already been taken"
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "name length validation" do
    @user.name = "a" * 101
    assert_not @user.valid?
    assert_includes @user.errors[:name], "is too long (maximum is 100 characters)"
  end

  test "has many authentication tokens" do
    @user.save!
    token1 = @user.authentication_tokens.create!
    token2 = @user.authentication_tokens.create!
    
    assert_equal 2, @user.authentication_tokens.count
    assert_includes @user.authentication_tokens, token1
    assert_includes @user.authentication_tokens, token2
  end

  test "has many sessions" do
    @user.save!
    session1 = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test Browser")
    session2 = @user.sessions.create!(ip_address: "192.168.1.1", user_agent: "Another Browser")
    
    assert_equal 2, @user.sessions.count
    assert_includes @user.sessions, session1
    assert_includes @user.sessions, session2
  end

  test "destroying user destroys associated authentication tokens" do
    @user.save!
    @user.authentication_tokens.create!
    @user.authentication_tokens.create!
    
    assert_difference "AuthenticationToken.count", -2 do
      @user.destroy
    end
  end

  test "destroying user destroys associated sessions" do
    @user.save!
    @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
    @user.sessions.create!(ip_address: "192.168.1.1", user_agent: "Test")
    
    assert_difference "Session.count", -2 do
      @user.destroy
    end
  end

  test "does not require password" do
    user = User.new(name: "No Password User", email_address: "nopass@example.com")
    assert user.valid?
    assert user.save
  end
end
