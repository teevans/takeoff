class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :authentication_tokens, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :sent_invitations, class_name: "CompanyInvitation", foreign_key: "invited_by_id", dependent: :nullify
  has_many :notification_subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_notification_settings, dependent: :destroy
  has_many :notification_batches, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :phone_number, with: ->(p) { p&.gsub(/\D/, "") }

  validates :email_address, presence: true,
                           uniqueness: { case_sensitive: false },
                           format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
  validates :phone_number, allow_blank: true, format: { with: /\A\d{10,15}\z/ }

  def pending_invitations
    CompanyInvitation.for_email(email_address).pending
  end

  def has_companies?
    companies.any?
  end

  def administrator_of?(company)
    company_users.where(company: company, role: "administrator").exists?
  end

  def member_of?(company)
    company_users.where(company: company).exists?
  end

  def phone_verified?
    phone_verified_at.present? && phone_number.present?
  end

  def notification_setting_for(company)
    user_notification_settings.find_or_create_by(company: company)
  end

  def notification_subscription_for(company, notification_type)
    notification_subscriptions.find_or_create_by(
      company: company,
      notification_type: notification_type
    ) do |sub|
      sub.email_enabled = notification_type.default_enabled
    end
  end

  def notify!(company:, type_key:, title:, body:, data: {})
    Notification.notify!(
      user: self,
      company: company,
      type_key: type_key,
      title: title,
      body: body,
      data: data
    )
  end

  def setup_default_notification_subscriptions(company)
    NotificationType.find_each do |type|
      notification_subscription_for(company, type)
    end
  end

  def unread_notifications_count(company = nil)
    scope = notifications.unread
    scope = scope.for_company(company) if company
    scope.count
  end
end
