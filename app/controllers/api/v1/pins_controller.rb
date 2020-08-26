class Api::V1::PinsController < ApplicationController
  def index
    @pins = Pin.all
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
    @pin.ipfs_update
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
