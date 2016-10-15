class HashtagsController < ApplicationController
  def index
		@hashtags = Hashtag.all
  end

	def new
	end

	def show
		@hashtag = Hashtag.find(params[:id])
	end

	def create
		@hashtag = Hashtag.new(hashtag_params)

		@hashtag.save
		redirect_to @hashtag
	end

	private
		def hashtag_params
			params.require(:hashtag).permit(:phrase)
		end
end
