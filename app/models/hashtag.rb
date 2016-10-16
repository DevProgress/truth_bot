class Hashtag < ApplicationRecord
  belongs_to :topic
  scope :active, -> {where(active: true)}
end
