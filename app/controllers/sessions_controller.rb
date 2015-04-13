class SessionsController < ApplicationController
  def new
    redirect_to :root if session[:user_id]
  end

  def create
    user = User.find_by username: params[:username]
    if user && user.authenticate(params[:password])
      if user.role == User::Role::BANNED
        redirect_to root_path, notice: 'Failed to log in: You have been banned'
      else
        session[:user_id] = user.id
        redirect_to user, notice: "Welcome back #{user.username}!"
      end
    else
      redirect_to :back, notice: 'Invalid username or password'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to :root
  end
end