class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :telegram_id, null: false, index: { unique: true }
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :language_code, default: 'ru'
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
