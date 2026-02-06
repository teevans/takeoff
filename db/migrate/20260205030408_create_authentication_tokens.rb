class CreateAuthenticationTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :authentication_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :authentication_tokens, :token, unique: true
    add_index :authentication_tokens, :code
    add_index :authentication_tokens, [ :user_id, :expires_at ]
  end
end
