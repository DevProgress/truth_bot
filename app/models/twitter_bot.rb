class TwitterBot < ApplicationRecord
  validates :twitter_handle, presence: true
  validates :key, presence: true
  validates :secret, presence: true
  validates :token, presence: true
  validates :token_secret, presence: true
end
