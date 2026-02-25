class User < ApplicationRecord
  has_many :quiz_sessions, dependent: :destroy
  
  validates :telegram_id, presence: true, uniqueness: true
  
  def self.find_or_create_from_telegram(telegram_data)
    telegram_id = telegram_data[:id] || telegram_data['id']
    return nil unless telegram_id
    
    user = find_or_initialize_by(telegram_id: telegram_id.to_s)
    
    if user.new_record? || user.changed?
      user.username = telegram_data[:username] || telegram_data['username']
      user.first_name = telegram_data[:first_name] || telegram_data['first_name']
      user.last_name = telegram_data[:last_name] || telegram_data['last_name']
      user.language_code = telegram_data[:language_code] || telegram_data['language_code'] || 'ru'
      # URL аватарки пользователя (для Telegram WebApp приходит как photo_url)
      avatar_url = telegram_data[:photo_url] || telegram_data['photo_url']
      user.avatar_url = avatar_url if avatar_url.present?
      user.save!
    end
    
    user
  end
end
