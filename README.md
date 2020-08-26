# TODO

- default pins#index filter (status = 'pinned')
- pins#index api filters (cids, name, status, before, after, limit, meta)

- update status after adding/updating

- `info` method on model
- pin status info
  - status_details
  - dag_size
  - raw_size
  - pinned_until

- actually use origins and delegates (must return at least one delegate)

- queue for pinning in the background (sidekiq, recording state in `status`)

- access token authentication

- basic pinning client for testing

- only unpin cid if this is the only pin with that CID

# Notes

Does NOT support pinning IPNS names at the moment
