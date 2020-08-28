class Api::V1::PinsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @limit = [1, params[:limit].to_i, 1000].sort[1]
    statuses = params[:status].to_s.split(',')
    @status = statuses.select{|s| Pin::STATUSES.include?(s)}
    @status = 'pinned' if @status.blank?
    @scope = Pin.order('created_at DESC').status(@status)

    @scope = @scope.name_contains(params[:name]) if params[:name].present?
    @scope = @scope.cid(params[:cid].split(',')) if params[:cid].present?
    @scope = @scope.before(params[:before]) if params[:before].present?
    @scope = @scope.after(params[:after]) if params[:after].present?
    @scope = @scope.meta(JSON.parse(params[:meta])) if params[:meta].present?

    @count = @scope.count
    @pins = @count > 0 ? @scope.limit(@limit) : []
  end

  def show
    @pin = Pin.find(params[:id])
  end

  def create
    @pin = Pin.new(pin_params)
    if @pin.save!
      @pin.ipfs_add
    end
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
    head :ok
  end

  protected

  def pin_params
    params.permit(:cid, :name, :origins, :meta)
  end
end
