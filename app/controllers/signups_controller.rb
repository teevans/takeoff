class SignupsController < ApplicationController
  allow_unauthenticated_access

  def new
    render inertia: {}
  end

  def create
    @user = User.new(signup_params)

    if @user.save
      session[:pending_email] = @user.email_address

      token = @user.authentication_tokens.create!
      send_welcome_email(token)
      store_development_credentials(token) if Rails.env.development?

      redirect_to verify_session_path, notice: "Check your email to confirm your account"
    else
      redirect_to new_signups_path, inertia: { errors: @user.errors }
    end
  end

  private

  # ============================================================================
  # User Creation Methods
  # ============================================================================

  def signup_params
    params.permit(:email_address, :name)
  end

  # ============================================================================
  # Magic Link Methods
  # ============================================================================

  def send_welcome_email(token)
    AuthenticationMailer.with(
      user: @user,
      token: token.token,
      code: token.code
    ).welcome.deliver_later
  end

  def store_development_credentials(token)
    session[:dev_magic_code] = token.code
    session[:dev_magic_url] = verify_session_url(token: token.token)
  end
end
