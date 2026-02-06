class ProcessNotificationBatchesJob < ApplicationJob
  queue_as :default

  def perform
    # Find batches that are ready to be sent
    # A batch is ready if:
    # 1. It hasn't been sent yet (sent_at is nil)
    # 2. It was created more than the user's batch time ago
    
    NotificationBatch.pending.find_each do |batch|
      process_batch(batch)
    end
  end

  private

  def process_batch(batch)
    # Get all notifications in this batch
    notifications = batch.notifications.includes(:user, :company, :notification_type)
    
    return if notifications.empty?
    
    # Group by user for sending
    notifications_by_user = notifications.group_by(&:user)
    
    notifications_by_user.each do |user, user_notifications|
      # Check if we're still in quiet hours for this user
      settings = user.notification_setting_for(user_notifications.first.company)
      next if in_quiet_hours?(settings)
      
      # Send the batched email
      NotificationMailer.with(
        user: user,
        notifications: user_notifications
      ).notification_batch.deliver_later
    end
    
    # Mark the batch as sent
    batch.update!(sent_at: Time.current)
  end

  def in_quiet_hours?(settings)
    current_time = Time.current.in_time_zone(settings.timezone)
    start_hour = settings.quiet_hours_start.hour
    start_min = settings.quiet_hours_start.min
    end_hour = settings.quiet_hours_end.hour
    end_min = settings.quiet_hours_end.min
    
    current_minutes = current_time.hour * 60 + current_time.min
    start_minutes = start_hour * 60 + start_min
    end_minutes = end_hour * 60 + end_min
    
    if start_minutes <= end_minutes
      # Normal case: quiet hours don't span midnight
      current_minutes.between?(start_minutes, end_minutes)
    else
      # Quiet hours span midnight
      current_minutes >= start_minutes || current_minutes <= end_minutes
    end
  end
end