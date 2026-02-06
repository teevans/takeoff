class CreateNotificationTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_types do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :category, null: false
      t.boolean :default_enabled, default: true, null: false
      t.boolean :force_enabled, default: false, null: false
      t.json :channels, default: ['email']

      t.timestamps
    end

    add_index :notification_types, :key, unique: true
    add_index :notification_types, :category
  end
end
