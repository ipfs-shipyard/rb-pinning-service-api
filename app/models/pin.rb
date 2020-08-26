class Pin < ApplicationRecord
  validates_presence_of :cid

  def ipfs_client
    @client ||= Ipfs::Client.new 'http://localhost:5001'
  end

  def ipfs_add
    ipfs_client.pin_add(cid)
  end

  def ipfs_remove
    ipfs_client.pin_rm(cid)
  end

  def ipfs_update
    # TODO implement this in client
  end

  def ipfs_verify
    # TODO implement this in client
  end
end
