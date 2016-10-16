class ResponsesController < ApplicationController
  def index
		@responses = Response.all
  end

	def show
		@response = Response.find(params[:id])
	end

	def new
		@topics = Topic.all
	end

	def edit
		@response = Response.find(params[:id])
		@hashtags = Topic.all
	end

	def create
		@response = Response.new(response_params)
		@response.save
		redirect_to @response
	end

	def update
		@response = Response.find(params[:id])

		if @response.update(response_params)
			redirect_to @response
		else
			render 'edit'
		end
	end

	private
		def response_params
			params.require(:response).permit(:text, :topic_id)
		end

end
