class Pin < ApplicationRecord
  validates_presence_of :cid

  def ipfs_client
    @client ||= Ipfs::Client.new 'http://localhost:5001'
  end

  def ipfs_add
    ipfs_client.pin_add(cid)
  end

  def ipfs_remove
    # TODO only unpin cid if this is the only pin with that CID
    ipfs_client.pin_rm(cid)
  end

  def ipfs_update(before_cid, after_cid)
    # TODO implement proper pin_update in client
    ipfs_client.pin_add(after_cid)
    # TODO only unpin cid if this is the only pin with that CID
    ipfs_client.pin_rm(before_cid)
  end

  def info
    # TODO implement this
    {}
  end

  def ipfs_verify
    # TODO implement this in client
  end
end
