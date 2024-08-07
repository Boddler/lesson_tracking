class Pull < ApplicationRecord
  has_many :scrapes, dependent: :destroy
end
