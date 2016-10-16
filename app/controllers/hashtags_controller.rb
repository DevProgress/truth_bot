class HashtagsController < ApplicationController
  def index
		@hashtags = Hashtag.all
		@topics = Topic.all
  end

	def new
		@topics = Topic.all
	end

	def show
		@hashtag = Hashtag.find(params[:id])
		puts 'vjw'
		puts @hashtag.topic_id
		@topic = Topic.find(@hashtag.topic_id)
	end

	def edit
		@hashtag = Hashtag.find(params[:id])
	end

	def create
		puts hashtag_params
		@hashtag = Hashtag.new(hashtag_params)

		@hashtag.save
		redirect_to @hashtag
	end

	def update
		@hashtag = Hashtag.find(params[:id])

		if @hashtag.update(hashtag_params)
			redirect_to @hashtag
		else
			render 'edit'
		end
	end

	private
		def hashtag_params
			params.require(:hashtag).permit(:phrase, :topic_id)
		end
end
