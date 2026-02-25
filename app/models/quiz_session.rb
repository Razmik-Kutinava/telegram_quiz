class QuizSession < ApplicationRecord
  belongs_to :user
  belongs_to :season
  
  validates :result_type, presence: true
  validates :result_label, presence: true
  validates :user_id, uniqueness: { scope: :season_id, message: "уже прошел квиз в этом сезоне" }
  
  before_create :set_started_at, if: -> { started_at.nil? }
  before_save :parse_answers_json, if: -> { answers_json.is_a?(Hash) || answers_json.is_a?(Array) }
  
  def answers
    return {} if answers_json.blank?
    JSON.parse(answers_json) rescue {}
  end
  
  def answers=(data)
    self.answers_json = data.to_json
  end
  
  def completed?
    completed_at.present?
  end
  
  private
  
  def set_started_at
    self.started_at = Time.current
  end
  
  def parse_answers_json
    self.answers_json = answers_json.to_json if answers_json.is_a?(Hash) || answers_json.is_a?(Array)
  end
end
