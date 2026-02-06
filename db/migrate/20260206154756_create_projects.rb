class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :project_type, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :status, default: "planning", null: false
      t.decimal :budget, precision: 12, scale: 2
      t.date :start_date
      t.date :estimated_completion_date

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :project_type
    add_index :projects, [:company_id, :status]
  end
end