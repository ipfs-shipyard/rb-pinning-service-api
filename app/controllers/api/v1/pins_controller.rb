class Api::V1::PinsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @pagy, @pins = pagy(Pin.order('created_at DESC'), overflow: :empty_page)
  end

  def show
    @pin = Pin.find(params[:id])
  end

  def create
    @pin = Pin.new(pin_params)
    @pin.save!
  end

  def update
    @pin = Pin.find(params[:id])
    @pin.update(pin_params)
    if @pin.saved_change_to_cid
      @pin.ipfs_update(@pin.saved_change_to_cid[0], @pin.saved_change_to_cid[1])
    end
  end

  def destroy
    @pin = Pin.find(params[:id])
    @pin.ipfs_remove
    @pin.destroy
  end

  protected

  def pin_params
    params.permit(:cid, :name, :origins, :meta)
  end
end
