class NotificationCenterController < ApplicationController

  def index
    @notifications = Current.user.notifications
                                 .where(company: Current.company)
                                 .includes(:notification_type)
                                 .order(created_at: :desc)
                                 .limit(50)
    
    @unread_count = Current.user.notifications
                                .where(company: Current.company, read_at: nil)
                                .count
    
    render inertia: 'notification_center/index', props: {
      notifications: @notifications.map { |n| serialize_notification(n) },
      unread_count: @unread_count
    }
  end

  def mark_read
    notification = Current.user.notifications
                              .where(company: Current.company)
                              .find(params[:id])
    
    notification.mark_as_read!
    redirect_to notification_center_path
  end

  def mark_all_read
    Current.user.notifications
                .where(company: Current.company, read_at: nil)
                .update_all(read_at: Time.current)
    
    redirect_to notification_center_path
  end

  private

  def serialize_notification(notification)
    {
      id: notification.id,
      title: notification.title,
      body: notification.body,
      data: notification.data,
      read_at: notification.read_at,
      created_at: notification.created_at,
      notification_type: {
        id: notification.notification_type.id,
        name: notification.notification_type.name,
        category: notification.notification_type.category
      }
    }
  end
end