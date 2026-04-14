# frozen_string_literal: true

class Feedback < ApplicationRecord
  belongs_to :match_report

  enum :severity, {
    info:    0,
    warning: 1,
    error:   2,
    success: 3
  }

  validates :analyzer, presence: true
  validates :category, presence: true
  validates :title, presence: true
  validates :severity, presence: true

  scope :by_severity, ->(s) { where(severity: s) }
  scope :errors_first, -> { order(severity: :desc, confidence_score: :desc) }
end
