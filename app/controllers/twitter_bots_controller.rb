class TwitterBotsController < ApplicationController
	before_action :check_admin

	def check_admin
		if !current_user or !current_user.admin?
			flash[:danger] = "You are not authorized to perform this action."
    	redirect_to menu_path
		end
	end

  def index
		@twitter_bots = TwitterBot.all.order("active DESC, id DESC")
  end

	def new
	end

	def show
		@twitter_bot = TwitterBot.find(params[:id])
	end

	def create
		@twitter_bot = TwitterBot.new(twitter_bot_params)
		save = @twitter_bot.save
		if save
			flash[:success] = "Twitter Bot created!"
			redirect_to twitter_bots_path
		else
			flash[:danger] = "Error. Make sure all fields are included."
			redirect_to new_twitter_bot_path
		end
	end

	private
		def twitter_bot_params
			params.require(:twitter_bot).permit(:key, :secret, :token, :token_secret, :active)
		end

end
