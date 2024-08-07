class PullsController < ApplicationController
  def create
  end

  def destroy
    pull = Pull.find(params[:id])
    if pull.destroy
      if Scrape.where(user_id: session[:user_id]).any?
        redirect_to scrapes_path, notice: "Pull was successfully destroyed"
      else
        redirect_to root_path, notice: "Pull was successfully destroyed"
      end
    else
      redirect_to scrapes_path, notice: "Error - nothing deleted"
    end
  end
end
