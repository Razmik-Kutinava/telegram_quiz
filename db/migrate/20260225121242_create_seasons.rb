class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.datetime :started_at
      t.datetime :ended_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    
    add_index :seasons, :active
  end
end
