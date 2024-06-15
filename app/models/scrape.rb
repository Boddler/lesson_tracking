class Scrape < ApplicationRecord
  has_many :lessons, dependent: :destroy
end
