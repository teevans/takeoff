class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create verify ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    render inertia: {}
  end

  def create
    email = params[:email_address]
    @user = User.find_by(email_address: email)

    # Store email in session for verify form
    session[:pending_email] = email

    if @user
      token = @user.authentication_tokens.create!
      AuthenticationMailer.with(user: @user, token: token.token, code: token.code).magic_link.deliver_later

      # Show magic link info in development
      if Rails.env.development?
        session[:dev_magic_code] = token.code
        session[:dev_magic_url] = verify_session_url(token: token.token)
      end
    end

    redirect_to verify_session_path, notice: "Check your email for a verification code"
  end

  def verify
    # If no params, just show the verify form with the pending email
    if params[:token].blank? && params[:code].blank?
      # Redirect to login if no email in session
      if session[:pending_email].blank?
        redirect_to new_session_path, alert: "Please enter your email first"
        return
      end

      dev_info = if Rails.env.development? && session[:dev_magic_code]
        {
          code: session.delete(:dev_magic_code),
          url: session.delete(:dev_magic_url)
        }
      end

      render inertia: {
        pending_email: session[:pending_email],
        dev_info: dev_info
      }
      return
    end

    # Use pending email from session if not provided
    email_address = params[:email_address] || session[:pending_email]

    token = if params[:token]
      AuthenticationToken.find_by_valid_token(params[:token])
    elsif params[:code] && email_address
      user = User.find_by(email_address: email_address)
      AuthenticationToken.find_by_valid_code(params[:code], user&.id) if user
    end

    if token
      token.use!
      session.delete(:pending_email) # Clean up
      start_new_session_for token.user
      redirect_to after_authentication_url, notice: "Successfully signed in!"
    else
      redirect_to new_session_path, alert: "Invalid or expired link. Please try again."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
