class Season < ApplicationRecord
  has_many :quiz_sessions, dependent: :destroy
  
  validates :name, presence: true
  
  scope :active, -> { where(active: true) }
  
  def self.current
    active.order(created_at: :desc).first
  end
end
