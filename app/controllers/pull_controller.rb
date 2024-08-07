class PullController < ApplicationController
  def create
  end

  def destroy
    pull = Pull.find(params[:id])
    if pull.destroy
      redirect_to scrapes_path, notice: "Pull was successfully destroyed"
    else
      redirect_to root, notice: "Error - nothing deleted"
    end
  end
end
