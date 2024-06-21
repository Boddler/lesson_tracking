class Slot < ApplicationRecord
  belongs_to :scrape
  belongs_to :lesson
end
