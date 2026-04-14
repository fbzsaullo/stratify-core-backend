# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.references :match_report, null: false, foreign_key: true
      t.string :analyzer, null: false
      t.integer :severity, null: false, default: 0  # 0: info, 1: warning, 2: error, 3: success
      t.string :category, null: false                # aim, utility, decision_making, positioning
      t.string :title, null: false
      t.text :description
      t.text :actionable_tip
      t.float :confidence_score, default: 0.0
      t.json :raw_payload, default: {}

      t.timestamps
    end

    add_index :feedbacks, [:match_report_id, :severity]
    add_index :feedbacks, [:match_report_id, :category]
  end
end
