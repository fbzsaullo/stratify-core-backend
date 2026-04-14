# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.string :steam_id, null: false, index: { unique: true }
      t.string :username, null: false
      t.integer :rank, default: 0

      t.timestamps
    end
  end
end
