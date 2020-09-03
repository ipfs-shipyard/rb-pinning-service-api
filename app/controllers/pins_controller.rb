class PinsController < ApplicationController
  def index
    @pagy, @pins = pagy(Pin.not_deleted.order('created_at DESC'))
  end

  def new
    @pin = Pin.new
  end

  def create
    @pin = Pin.new(pin_params)
    if @pin.save
      @pin.ipfs_add_async
      redirect_to @pin
    else
      render :new
    end
  end

  def destroy
    @pin = Pin.not_deleted.find(params[:id])
    @pin.ipfs_remove_async
    @pin.mark_deleted
    redirect_to pins_path
  end

  def show
    @pin = Pin.not_deleted.find(params[:id])
  end

  def update
    @existing_pin = Pin.not_deleted.find(params[:id])
    @pin = Pin.new(pin_params)
    if @pin.save!
      @pin.ipfs_add_async
      @existing_pin.ipfs_remove_async
      @existing_pin.mark_deleted
      redirect_to @pin
    else
      render :edit
    end
  end

  def edit
    @pin = Pin.find(params[:id])
  end

  protected

  def pin_params
    params.require(:pin).permit(:cid, :name)
  end
end
