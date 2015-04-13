class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :set_role]
  before_action only: [:edit, :update, :destroy] do
    redirect_to root_path unless current_user == @user
  end
  before_action only: [:set_role] do
    redirect_to root_path unless can_modify_this_user_roles?(@user)
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if current_user != @user
      @friendship = Friendship.friendship_for(current_user, @user)
      if @friendship.nil?
        @friendship = Friendship.new
        @friendship.friend = @user
      end
    end

    if can_modify_this_user_roles?(@user)
      @roles = [{ name: 'Regular', id: User::Role::NORMAL},
                { name: 'Banned', id: User::Role::BANNED},
                { name: 'Moderator', id: User::Role::MODERATOR}]
      if (current_user.has_admin_privileges?)
        @roles << { name: 'Admin', id: User::Role::ADMIN}
      end
    end
  end

  def set_role
    @user.skip_password_validation = true
    @user.role = params[:role]
    @user.save
    redirect_to user_path @user
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.role = User::Role::NORMAL

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :password, :password_confirmation)
    end
end
