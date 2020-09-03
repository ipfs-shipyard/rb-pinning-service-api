class IpfsAddWorker
  include Sidekiq::Worker

  def perform(pin_id)
    Pin.find_by_id(pin_id).try(:ipfs_add)
  end
end
