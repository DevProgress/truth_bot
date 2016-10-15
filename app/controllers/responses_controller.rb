class ResponsesController < ApplicationController
  def index
		@responses = Response.all
  end

	def new
		@hashtags = Hashtag.all.pluck(:phrase)
	end

	def show
		@response = Response.find(params[:id])
	end

	def create
		@response = Response.new(response_params)

		@response.save
		redirect_to @response
	end

	private
		def response_params
			params.require(:response).permit(:text, :hashtag_id)
		end

end
