class CreateQuizSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_sessions do |t|
      t.references :user, null: false, foreign_key: true, type: :integer
      t.references :season, null: false, foreign_key: true, type: :integer
      t.string :result_type, null: false
      t.string :result_label, null: false
      t.text :answers_json
      t.datetime :started_at
      t.datetime :completed_at
      t.string :source # organic / ad / broadcast
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    
    add_index :quiz_sessions, [:user_id, :season_id], unique: true
    # Индексы на user_id и season_id уже создаются автоматически через t.references
    add_index :quiz_sessions, :completed_at
  end
end
