class Topic < ApplicationRecord
	has_many :hashtags
	has_many :responses
end
