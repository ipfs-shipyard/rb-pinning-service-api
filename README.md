# TODO

- basic pinning client for testing

- only unpin cid if this is the only pin with that CID

- pins#index pagination (by before)
- pins#index api filters (cids, name, status, before, after, limit, meta)

- access token authentication

- update status after adding/updating

- `info` method on model
- pin status info
  - status_details
  - dag_size
  - raw_size
  - pinned_until

- actually use origins and delegates (must return at least one delegate)

- queue for pinning in the background (sidekiq, recording state in `status`)


# Notes

Does NOT support pinning IPNS names at the moment
