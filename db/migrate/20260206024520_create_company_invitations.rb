class CreateCompanyInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :company_invitations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :email, null: false
      t.string :role, null: false, default: 'member'
      t.string :token, null: false
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :company_invitations, :token, unique: true
    add_index :company_invitations, :email
  end
end
