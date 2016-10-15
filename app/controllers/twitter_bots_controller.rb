class TwitterBotsController < ApplicationController
  def index
		@twitter_bots = TwitterBot.all
  end

	def new
	end

	def show
		@twitter_bot = TwitterBot.find(params[:id])
	end

	def create
		@twitter_bot = TwitterBot.new(twitter_bot_params)

		@twitter_bot.save
		redirect_to @twitter_bot
	end

	private
		def twitter_bot_params
			params.require(:twitter_bot).permit(:key, :secret, :token, :token_secret, :active)
		end

end
