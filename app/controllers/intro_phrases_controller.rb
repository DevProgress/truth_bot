class IntroPhrasesController < ApplicationController
  before_action :check_admin

  def check_admin
    if !current_user or !current_user.admin?
      flash[:danger] = "You are not authorized to perform this action."
      redirect_to menu_path
    end
  end
  
  def index
    @intro_phrases = IntroPhrase.all
  end

  def show
    @intro_phrase = IntroPhrase.find(params[:id])
  end

  def new
    @intro_phrase = IntroPhrase.new
  end

  def edit
    @intro_phrase = IntroPhrase.find(params[:id])
  end

  def create
    @intro_phrase = IntroPhrase.new(topic_params)
    @intro_phrase.save
    redirect_to @intro_phrase
  end

  def update
    @intro_phrase = IntroPhrase.find(params[:id])

    if @intro_phrase.update(intro_phrase_params)
      redirect_to @intro_phrase
    else
      redirect_to 'edit'
    end

  end


  private
    def intro_phrase_params
      params.require(:intro_phrase).permit(:text, :pro_hillary)
    end
end
