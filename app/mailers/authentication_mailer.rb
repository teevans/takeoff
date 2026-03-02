class AuthenticationMailer < ApplicationMailer
  def magic_link
    @user = params[:user]
    @token = params[:token]
    @code = params[:code]
    @url = verify_session_url(token: @token)

    mail(
      to: @user.email_address,
      subject: "Your magic link to sign in"
    )
  end

  def welcome
    @user = params[:user]
    @token = params[:token]
    @code = params[:code]
    @url = verify_session_url(token: @token)

    mail(
      to: @user.email_address,
      subject: "Welcome! Confirm your email address"
    )
  end
end