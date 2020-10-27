class Api::V1::PinsController < Api::V1::ApplicationController
  before_action :authenticate_user!

  def index
    @limit = [1, params[:limit].to_i, 1000].sort[1]
    statuses = params[:status].to_s.split(',')
    @status = statuses.select{|s| Pin::STATUSES.include?(s)}
    @status = 'pinned' if @status.blank?
    @scope = current_user.pins.not_deleted.order('created_at DESC').status(@status)

    if params[:name].present?
      case params[:match]
      when 'iexact'
        @scope = @scope.where('name ilike ?', params[:name])
      when 'partial'
        @scope = @scope.where('name like ?', "%#{params[:name]}%")
      when 'ipartial'
        @scope = @scope.where('name ilike ?', "%#{params[:name]}%")
      else
        @scope = @scope.where(name: params[:name])
      end
    end

    @scope = @scope.cids(params[:cid].split(',').first(10)) if params[:cid].present?
    @scope = @scope.before(params[:before]) if params[:before].present?
    @scope = @scope.after(params[:after]) if params[:after].present?
    @scope = @scope.meta(JSON.parse(params[:meta])) if params[:meta].present?

    @count = @scope.count
    @pins = @count > 0 ? @scope.limit(@limit) : []
  end

  def show
    @pin = current_user.pins.not_deleted.find(params[:id])
  end

  def create
    @pin = current_user.pins.build(pin_params)
    if @pin.save!
      @pin.ipfs_add_async
    end
  end

  def update
    @existing_pin = current_user.pins.not_deleted.find(params[:id])
    @pin = current_user.pins.build(pin_params)
    if @pin.save!
      @pin.ipfs_add_async
      @existing_pin.ipfs_remove_async
      @existing_pin.mark_deleted
    end
  end

  def destroy
    @pin = current_user.pins.not_deleted.find(params[:id])
    @pin.ipfs_remove_async
    @pin.mark_deleted
    head :accepted
  end

  protected

  def pin_params
    params.permit(:cid, :name, :origins, :meta)
  end
end
