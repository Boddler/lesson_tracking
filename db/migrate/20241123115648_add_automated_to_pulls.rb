class AddAutomatedToPulls < ActiveRecord::Migration[7.0]
  def change
    add_column :pulls, :automated, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        Pull.update_all(automated: false)
      end
    end
  end
end
