# TODO

- basic pinning client for testing

- pin name max length 255
- `status` should be one of "queued" "pinning" "pinned" "failed"
- `origins` should be an array
- `meta` should be json
- `delegates` should be an array
- `info` should be json (or method on model)

- only unpin cid if this is the only pin with that CID

- pins#index pagination
- pins#index api filters (cids, name, status, before, after, limit, meta)

- access token authentication

- pin status info
  - status_details
  - dag_size
  - raw_size
  - pinned_until

- actually use origins and delegates

- check that POST to update works as expected (instead of PUT)

- queue for pinning in the background (sidekiq, recording state in `status`)

- clarification on pinning IPNS names
- clarification pagination (by page number, offset, date etc)
- clarification pagination overflow
