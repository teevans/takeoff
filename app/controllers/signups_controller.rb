class SignupsController < ApplicationController
  allow_unauthenticated_access

  def new
    render inertia: {}
  end

  def create
    @user = User.new(signup_params)

    if @user.save
      # Store email in session for verify form
      session[:pending_email] = @user.email_address

      token = @user.authentication_tokens.create!
      AuthenticationMailer.with(user: @user, token: token.token, code: token.code).welcome.deliver_later

      # Show magic link info in development
      if Rails.env.development?
        session[:dev_magic_code] = token.code
        session[:dev_magic_url] = verify_session_url(token: token.token)
      end

      redirect_to verify_session_path, notice: "Check your email to confirm your account"
    else
      redirect_to new_signups_path, inertia: { errors: @user.errors }
    end
  end

  private

  def signup_params
    params.permit(:email_address, :name)
  end
end
