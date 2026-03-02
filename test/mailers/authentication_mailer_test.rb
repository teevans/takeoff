require "test_helper"

class AuthenticationMailerTest < ActionMailer::TestCase
  def setup
    @user = User.create!(name: "Test User", email_address: "test@example.com")
    @token = @user.authentication_tokens.create!
  end

  test "magic_link" do
    mail = AuthenticationMailer.with(
      user: @user,
      token: @token.token,
      code: @token.code
    ).magic_link

    assert_equal "Your magic link to sign in", mail.subject
    assert_equal [@user.email_address], mail.to
    assert_equal ["from@example.com"], mail.from

    assert_match @user.name, mail.body.encoded
    assert_match @token.code, mail.body.encoded
    assert_match "verify", mail.body.encoded
    assert_match @token.token, mail.body.encoded
    assert_match "15 minutes", mail.body.encoded
  end

  test "welcome" do
    mail = AuthenticationMailer.with(
      user: @user,
      token: @token.token,
      code: @token.code
    ).welcome

    assert_equal "Welcome! Confirm your email address", mail.subject
    assert_equal [@user.email_address], mail.to
    assert_equal ["from@example.com"], mail.from

    assert_match @user.name, mail.body.encoded
    assert_match @token.code, mail.body.encoded
    assert_match "verify", mail.body.encoded
    assert_match @token.token, mail.body.encoded
    assert_match "Welcome", mail.body.encoded
    assert_match "15 minutes", mail.body.encoded
  end

  test "magic_link includes clickable link" do
    mail = AuthenticationMailer.with(
      user: @user,
      token: @token.token,
      code: @token.code
    ).magic_link

    assert_match %r{/session/verify\?token=#{@token.token}}, mail.body.encoded
  end

  test "welcome includes clickable link" do
    mail = AuthenticationMailer.with(
      user: @user,
      token: @token.token,
      code: @token.code
    ).welcome

    assert_match %r{/session/verify\?token=#{@token.token}}, mail.body.encoded
  end

  test "emails include both HTML and text parts" do
    mail = AuthenticationMailer.with(
      user: @user,
      token: @token.token,
      code: @token.code
    ).magic_link

    assert_equal 2, mail.parts.size
    assert_equal "text/plain", mail.parts.first.content_type.split(";").first
    assert_equal "text/html", mail.parts.last.content_type.split(";").first
  end
end
