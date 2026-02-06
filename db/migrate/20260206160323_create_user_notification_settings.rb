class CreateUserNotificationSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :email_batch_minutes, default: 15, null: false
      t.time :quiet_hours_start, default: '19:00', null: false
      t.time :quiet_hours_end, default: '07:00', null: false
      t.string :timezone, default: 'UTC', null: false

      t.timestamps
    end

    add_index :user_notification_settings, [:user_id, :company_id], unique: true
  end
end
