# frozen_string_literal: true

class MatchReport < ApplicationRecord
  belongs_to :player
  has_many :feedbacks, dependent: :destroy

  enum :status, {
    pending:   0,
    analyzing: 1,
    complete:  2,
    failed:    3
  }

  validates :match_id, presence: true, uniqueness: true
  validates :map, presence: true
  validates :status, presence: true

  scope :completed, -> { where(status: :complete) }
  scope :recent, -> { order(created_at: :desc) }
end
