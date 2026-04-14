# frozen_string_literal: true

class CreateMatchReports < ActiveRecord::Migration[7.1]
  def change
    create_table :match_reports do |t|
      t.string :match_id, null: false, index: { unique: true }
      t.references :player, null: false, foreign_key: true
      t.string :map, null: false
      t.integer :status, null: false, default: 0  # 0: pending, 1: analyzing, 2: complete, 3: failed
      t.string :score
      t.integer :duration_seconds
      t.json :team_ct_ids, default: []
      t.json :team_t_ids, default: []

      t.timestamps
    end
  end
end
