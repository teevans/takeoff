class NotificationMailer < ApplicationMailer
  def send_notification
    @notification = params[:notification]
    @user = @notification.user
    @company = @notification.company

    mail(
      to: @user.email_address,
      subject: @notification.title
    )
  end

  def batch_notification
    @batch = params[:batch]
    @user = @batch.user
    @company = @batch.company
    @notifications = @batch.notification_records

    mail(
      to: @user.email_address,
      subject: "#{@company.name}: #{@batch.notifications.size} new notifications"
    )
  end
end