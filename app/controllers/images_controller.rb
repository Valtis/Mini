class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :destroy, :set_visibility]
  before_action  only: [:show] do
    redirect_to root_path unless has_right_to_see_image(@image)
  end
  before_action only: [:destroy] do
    verify_image_owner_or_moderator(@image)
  end

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show

    @visibility = %w[private friends public]
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  def set_visibility
    redirect_to root_path unless current_user and @image.user == current_user
    visibility = params[:visibility]
    if  visibility == 'private'
      @image.visibility = Image::Visibility::PRIVATE
    elsif visibility == 'friends'
      @image.visibility = Image::Visibility::FRIENDS
    elsif visibility == 'public'
      @image.visibility = Image::Visibility::PUBLIC
    else
      # probably some user getting bit too smart with their POSTs
      redirect_to root_path
    end

    @image.save

    redirect_to image_path(params[:id])
  end

  # POST /images
  # POST /images.json
  def create

    @image = Image.new(image_params)
    @image.user = current_user

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:S3Image)
    end

end
