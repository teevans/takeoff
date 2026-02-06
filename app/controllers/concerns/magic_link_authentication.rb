module MagicLinkAuthentication
  extend ActiveSupport::Concern

  private

  def development_info_for_verification_form
    return unless Rails.env.development? && session[:dev_magic_code]

    {
      code: session.delete(:dev_magic_code),
      url: session.delete(:dev_magic_url)
    }
  end
end
