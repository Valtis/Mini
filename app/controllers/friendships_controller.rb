class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [:accept, :destroy]
  before_action only: [:create, :destroy] do
    redirect_to root_path unless logged_in?
  end

  before_action :is_participant_in_friendship, only: [:destroy, :accept, :reject]

  # POST /friendships
  # POST /friendships.json
  def create


    @friendship = Friendship.new(friendship_params)
    @friendship.requester = current_user
    @friendship.status = Friendship::Status::PENDING

    if @friendship.save
        redirect_to :back, notice: 'Friendship request was successfully created.'
    else
        redirect_to :back, notice: "Failed to create the friendship. Validation failure: #{@friendship.errors.messages.to_a.flatten * ' '}"
    end
  end


  def accept
    @friendship.status = Friendship::Status::ACCEPTED
    @friendship.save
    redirect_to :back
  end

  # DELETE /friendships/1
  # DELETE /friendships/1.json
  def destroy
    @friendship.destroy
    redirect_to :back, notice: 'Friendship has been cancelled'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_friendship
      @friendship = Friendship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def friendship_params
      params.require(:friendship).permit(:requester_id, :friend_id, :status)
    end

    def is_participant_in_friendship
      if @friendship.requester != current_user && @friendship.friend != current_user
        redirect_to user_path, notice: 'Forbidden operation'
      end
    end
end
