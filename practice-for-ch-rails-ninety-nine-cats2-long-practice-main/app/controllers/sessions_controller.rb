class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    @user = User.find_by_credentials(params[:user][:username], params[:user][:password])

    if @users
      login(@user)
      redirect_to user_url(@user.id)
    else
      render :new
    end
  end
end
