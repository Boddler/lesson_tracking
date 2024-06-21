class Lesson < ApplicationRecord
  has_many :slots
  has_many :scrapes, through: :slots

  def self.find_or_create_by_attributes(attributes)
    sanitised_attributes = attributes.except("id", "created_at", "updated_at")
    Lesson.find_by(sanitised_attributes) || Lesson.create(sanitised_attributes)
  end
end
