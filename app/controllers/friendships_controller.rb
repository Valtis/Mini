class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [:destroy]
  before_action :is_logged_in, only: [:create, :destroy]
  before_action :is_participant_in_friendship, only: [:destroy]

  # POST /friendships
  # POST /friendships.json
  def create

    @friendship = Friendship.new(friendship_params)
    @friendship.requester = current_user
    @friendship.status = Friendship::Status::PENDING

    respond_to do |format|
      if @friendship.save
        format.html { redirect_to :back, notice: 'Friendship request was successfully created.' }
      else
        redirect :back, notice: 'Failed to create the friendship.'
      end
    end
  end


  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship.destroy
    respond_to do |format|
      format.html { redirect_to friendships_url, notice: 'Friendship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship
      @friendship = Friendship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def friendship_params
      params.require(:friendship).permit(:requesterId, :friendID, :status)
    end

    def is_participant_in_friendship
      if @friendship.requester != current_user && @friendship.friend != current_user
        redirect_to user_path, notice: 'Forbidden operation'
      end
    end
end
