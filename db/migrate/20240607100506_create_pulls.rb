class CreatePulls < ActiveRecord::Migration[7.1]
  def change
    create_table :pulls do |t|

      t.timestamps
    end
  end
end
