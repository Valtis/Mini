class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]

  before_action only: [:create] do
    redirect_to root_path unless logged_in?
  end

  before_action only: [:delete] do
    redirect_to root_path unless comment_owner_or_moderator?(@comment)
  end

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # POST /comments
  # POST /comments.json
  def create

    comment = Comment.new comment_params
    comment.user = current_user
    comment.save
    redirect_to image_path comment.image_id
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    image_id = @comment.image_id
    @comment.destroy
    redirect_to image_path image_id
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:text, :image_id, :user_id)
    end
end
