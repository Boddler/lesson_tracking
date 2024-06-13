class Update < ApplicationRecord
  has_many :lessons, dependent: :destroy
end
