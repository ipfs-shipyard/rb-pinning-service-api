class PinsController < ApplicationController
  def index
    @pagy, @pins = pagy(Pin.order('created_at DESC'))
  end

  def new
    @pin = Pin.new
  end

  def create
    @pin = Pin.new(pin_params)
    if @pin.save
      @pin.ipfs_add
      redirect_to @pin
    else
      render :new
    end
  end

  def destroy
    @pin = Pin.find(params[:id])
    @pin.ipfs_remove
    @pin.destroy
    redirect_to pins_path
  end

  def show
    @pin = Pin.find(params[:id])
  end

  def update
    @pin = Pin.find(params[:id])
    if @pin.update(pin_params)
      if @pin.saved_change_to_cid
        @pin.ipfs_update(@pin.saved_change_to_cid[0], @pin.saved_change_to_cid[1])
      end
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
