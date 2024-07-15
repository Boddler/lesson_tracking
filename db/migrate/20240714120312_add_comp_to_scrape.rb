class AddCompToScrape < ActiveRecord::Migration[7.1]
  def change
    add_column :scrapes, :comp_next, :jsonb, default: {}
    add_column :scrapes, :comp_this, :jsonb, default: {}

    reversible do |dir|
      dir.up do
        Scrape.reset_column_information
        Scrape.find_each do |scrape|
          scrape.update_column(:comp_next, { blues: 0, reds: 0, blue_comp: 0, red_comp: 0, total_comp: 0 })
          scrape.update_column(:comp_this, { blues: 0, reds: 0, blue_comp: 0, red_comp: 0, total_comp: 0 })
        end
      end
    end
  end
end
