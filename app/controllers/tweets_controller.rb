class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.limit(200).order("id DESC")
  end
end
