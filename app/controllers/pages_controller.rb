class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:home]
  def home
    redirect_to menu_path if current_user
  end

  def menu

  end
end
