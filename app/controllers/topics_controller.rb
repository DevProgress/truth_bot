class TopicsController < ApplicationController
  def index
		@topics = Topic.all
  end

  def show
		@topic = Topic.find(params[:id])
  end

  def new
  end

  def edit
		@topic = Topic.find(params[:id])
  end

	def create
		@topic = Topic.new(topic_params)
		@topic.save
		redirect_to @topic
	end

	def update
		@topic = Topic.find(params[:id])

		if @topic.update(topic_params)
			redirect_to @topic
		else
			redirect_to 'edit'
		end

	end


	private
		def topic_params
			params.require(:topic).permit(:name)
		end
end
