# TODO

- `info` method on model
- pin status info
  - status_details
  - dag_size
  - raw_size
  - pinned_until

- queue for pinning in the background (sidekiq, recording state in `status`)

- access token authentication

- basic pinning client for testing

- only unpin cid if this is the only pin with that CID

# Notes

- Does NOT support pinning IPNS names at the moment
- Pagination is manual for the client, no need for pagination library or headers in server
- assumes array in query params is comma seperated (cid=foo,bar)
