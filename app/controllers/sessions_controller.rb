class SessionsController < ApplicationController
  include MagicLinkAuthentication

  allow_unauthenticated_access only: %i[ new create verify ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    render inertia: {}
  end

  def create
    session[:pending_email] = params[:email_address]

    if user_exists_for_email?
      token = @user.authentication_tokens.create!
      send_magic_link_email(token)
      store_development_credentials(token) if Rails.env.development?
    end

    redirect_to verify_session_path, notice: "Check your email for a verification code"
  end

  def verify
    # Show verification form if no token or code provided
    if params[:token].blank? && params[:code].blank?
      if session[:pending_email].blank?
        redirect_to new_session_path, alert: "Please enter your email first"
        return
      end

      render inertia: {
        pending_email: session[:pending_email],
        dev_info: development_info_for_verification_form
      }
      return
    end

    token = find_authentication_token

    if token
      token.use!
      session.delete(:pending_email)
      start_new_session_for token.user
      redirect_after_authentication(token.user)
    else
      redirect_to new_session_path, alert: "Invalid or expired link. Please try again."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

  # ============================================================================
  # Authentication Methods
  # ============================================================================

  def find_authentication_token
    if params[:token].present?
      AuthenticationToken.find_by_valid_token(params[:token])
    elsif params[:code].present? && email_from_params_or_session
      user = User.find_by(email_address: email_from_params_or_session)
      AuthenticationToken.find_by_valid_code(params[:code], user.id) if user
    end
  end

  def redirect_after_authentication(user)
    if !user.has_companies?
      if user.pending_invitations.any?
        redirect_to companies_path, notice: "You have pending company invitations"
      else
        redirect_to new_company_path, notice: "Please create your first company"
      end
    else
      redirect_to after_authentication_url, notice: "Successfully signed in!"
    end
  end

  # ============================================================================
  # Magic Link Methods
  # ============================================================================

  def send_magic_link_email(token)
    AuthenticationMailer.with(
      user: @user,
      token: token.token,
      code: token.code
    ).magic_link.deliver_later
  end

  def store_development_credentials(token)
    session[:dev_magic_code] = token.code
    session[:dev_magic_url] = verify_session_url(token: token.token)
  end

  # ============================================================================
  # Helper Methods
  # ============================================================================

  def user_exists_for_email?
    @user = User.find_by(email_address: params[:email_address])
    @user.present?
  end

  def email_from_params_or_session
    params[:email_address] || session[:pending_email]
  end
end
