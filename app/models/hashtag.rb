class Hashtag < ApplicationRecord
  scope :active, -> {where(active: true)}
end
