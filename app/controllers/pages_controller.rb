class PagesController < ApplicationController
  def home
    @update = Update.new
  end

  def about
  end
end
