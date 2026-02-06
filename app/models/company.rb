class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :invitations, class_name: "CompanyInvitation", dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :notification_subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :user_notification_settings, dependent: :destroy
  has_many :notification_batches, dependent: :destroy

  validates :name, presence: true

  def self.create_with_owner(name:, owner:)
    transaction do
      company = create!(name: name)
      company.company_users.create!(user: owner, role: "administrator")
      company
    end
  end

  def add_member(user, role: "member")
    company_users.create!(user: user, role: role)
  end

  def administrators
    users.joins(:company_users).where(company_users: { role: "administrator" })
  end

  def members
    users.joins(:company_users).where(company_users: { role: "member" })
  end

  # Notify all users in company
  def notify_users(type_key:, title:, body:, data: {}, roles: nil)
    users_to_notify = roles ? users.joins(:company_users).where(company_users: { role: roles }) : users

    users_to_notify.find_each do |user|
      user.notify!(
        company: self,
        type_key: type_key,
        title: title,
        body: body,
        data: data
      )
    end
  end

  # Notify only administrators
  def notify_administrators(type_key:, title:, body:, data: {})
    notify_users(type_key: type_key, title: title, body: body, data: data, roles: "administrator")
  end

  # Notify only members
  def notify_members(type_key:, title:, body:, data: {})
    notify_users(type_key: type_key, title: title, body: body, data: data, roles: "member")
  end
end
