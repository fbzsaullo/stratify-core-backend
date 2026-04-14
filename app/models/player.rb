# frozen_string_literal: true

class Player < ApplicationRecord
  has_many :match_reports, dependent: :destroy

  validates :steam_id, presence: true, uniqueness: true
  validates :username, presence: true
end
