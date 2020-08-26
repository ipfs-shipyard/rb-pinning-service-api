class Pin < ApplicationRecord
  STATUSES = ["queued", "pinning", "pinned", "failed"]
  validates_presence_of :cid
  validates :status, inclusion: { in: STATUSES }

  scope :status, ->(status) { where(status: status.split(',')) }
  scope :cids, ->(cids) { where(cid: cids.split(',')) }
  scope :name_contains, ->(name) { where('name ilike ?', "%#{name}%") }
  scope :before, ->(before) { where('created_at < ?', before) }
  scope :after, ->(after) { where('created_at > ?', after) }
  scope :meta, ->(meta) {
    puts meta.first
    where("meta->>? = ?", meta.first[0], meta.first[1])
  }

  def ipfs_client
    # TODO this needs to be configurable
    @client ||= Ipfs::Client.new 'http://localhost:5001'
  end

  def ipfs_add
    begin
      update_columns(status: 'pinning')
      ipfs_client.pin_add(cid)
      update_columns(status: 'pinned')
    rescue => e
      puts e
      # TODO record the exception somewhere
      update_columns(status: 'failed')
    end
  end

  def ipfs_remove
    # TODO only unpin cid if this is the only pin with that CID
    ipfs_client.pin_rm(cid)
  end

  def ipfs_update(before_cid, after_cid)
    begin
      update_columns(status: 'pinning')
      ipfs_client.pin_add(after_cid)
      update_columns(status: 'pinned')
      # TODO only unpin cid if this is the only pin with that CID
      ipfs_client.pin_rm(before_cid)
    rescue => e
      # TODO record the exception somewhere
      update_columns(status: 'failed')
    end
  end

  def info
    # TODO implement this
    {}
  end

  def ipfs_verify
    # TODO implement this in client
  end
end
