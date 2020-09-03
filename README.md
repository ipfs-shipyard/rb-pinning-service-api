# IPFS Pinning Service API

A rails app that implements the [IPFS Pinning Service API](https://ipfs.github.io/pinning-services-api-spec/).

## Endpoints

The CRUD design of the pinning service API spec maps nicely onto the standard rails restful routing design with only a few minor tweaks needed to implement the full spec.

For the API, the default format is set to `:json` rather than HTML and CSRF protection is disabled, we've also nested the API routes under /api/v1 to seperate it from any html pages and allow deploying a v2 in the future without breaking compatibility with existing v1 clients.

TODO: implement authentication and access control via `Authorization: Bearer <access-token>`

The spec does not have any details around etag, gzip, last-modified and other headers that can help improve performance but these could be offered if the client supports them.

### [Create](https://ipfs.github.io/pinning-services-api-spec/#tag/pins/paths/~1pins/post)

POST request to /pins go to `pins#create`, rails will automatically parse the body as json and convert into params. Although the spec does not nest the object in a `pin` object like the ActiveRecord pattern, the keys do map nicely onto fields on our `Pin` database table.

We store `origins` in a postgresql `array` field and `meta` in a postgresql `jsonb` field which gives us some validation for free, the only required field is `cid` so that validation is set on the `Pin` model and `NOT NULL` at the database level. The `status` is defaulted to `queued` on newly created `Pin` records.

Before saving the `Pin` to the database, we also set the address of our local IPFS node in the `delegates` field, fetched using `ipfs id`.

After successful validation, the following steps are made to communicate with local IPFS node via http to pin the CID (pseudo ipfs commands included inline):

- set `status` to `pinning`
- attempt to connect to each `origin` (`ipfs swarm connect #{origin address}`)
- pin the `cid` (`ipfs pin add #{cid}`)
- set `status` to `pinned`
- if an error occurs then set `status` to `failed`

The spec says that a successful update results in a 202 (`:accepted`) response code with body of both the pin and it's status is then returned as JSON, rendered using the same jbuilder template as `pins#show`.

In rails the default is 200, as it appears that the spec assumes the ipfs actions will be happening in a job queue after the request has completed, although most http clients will accept and 2XX response as successful so this may not matter to much.

### List

GET request to /pins go to `pins#index` with optional url query params to filter responses. Default of 10 records per page (max `1000`), always ordered by newest first (`created_at DESC`).

Pagination is not the usual `?page=1` but instead the client is expected to work out the next page by passing the `created` field of the last record in a response as `before`, so order must always be the by creation date for pagination to work. (An alternative option here would be `offset` which would allow pagination and ordering at the same time).

`status` can be one or more of the four allowed statuses (`queued`, `pinning`, `pinned`, `failed`), comma separated and if `status` is not provided (or invalid), then it defaults to `pinned`, this are passed straight to ActiveRecord to filter on: `where(status: statuses)`.

One or more CID can be optionally passed, comma separated to `cid`, as they are case sensitive we can pass the array directly to ActiveRecord to filter on: `where(cid: cids)`.

Clients can optionally filter results by `name`, which can be an exact or partial case sensitive match, we use a case insensitive `like` query in postgresql for this: `where('name like ?', "%#{name}%")`.

Clients can optionally filter results by a key+value pair from the `meta` field, which is provided as json in the query parameter. Because we store `meta` in a `jsonb` field in postgresql, we can use the provided SQL function: `where("meta->>? = ?", meta.key, meta.value)`. The spec is not clear on if the JSON stored in `meta` can be nested, we allow nested JSON to be stored on creation but the query may not work as expected if nested JSON is passed when filtering.

`before` and `after` allow optional filtering by `created_at`, we can pass the date through to postgresql: `where('created_at < ?', before)` and `where('created_at > ?', after)` if present.

`count` is the total number of records available for the given filters, ignoring the `limit` we we make a separate SQL query for that before loading the limited `Pin` records, if `count` is zero we can skip the second SQL query and return an empty array.

The response of an array of both the pin and it's status is then returned as JSON, rendered using the same jbuilder partial as #show along with `count`.

This endpoint doesn't hit the IPFS node and would make a good candidate for caching.

### Get

GET request to /pins/{id} go to `pins#show` which renders `_pin_status.json.jbuilder` or returns 404 if the pin doesn't exist.

This endpoint doesn't hit the IPFS node and would make a good candidate for caching.

### Modify

POST request to /pins/{id} go to `pins#update`, unlike the standard rails pattern of using PATCH (or PUT in older versions of rails) for updates so we need to specify an extra route, we also leave the regular PATCH route pointing to the same place but it could be disabled for completeness.

This endpoint accepts the same request body as `pins#create`, rails will automatically parse the body as json and convert into params. Although the spec does not nest the object in a `pin` object like the ActiveRecord pattern, the keys do map nicely onto fields on our `Pin` database table.

Unlike in standard CRUD rails, the spec says that rather than updating the pin of the given `id`, a new pin should be created and the old pin removed afterwards.

> The user can modify an existing pin object via POST /pins/{id}. The new pin object id is returned in the PinStatus response. The old pin object is deleted automatically.

The response should return JSON for the newly created pin, not the pin of the given `id`.

It is unclear from the spec what should happen if the CID is the same as on the pin of the given `id`, for now we play it safe and remove the existing pin with `ipfs pin rm #{cid}` and recreate it with `ipfs pin add #{cid}` but we may be able to skip that step and just update the other fields on the database record.

It is also unclear when the pinning on the new CID fails, should the old pin still be deleted.

There is also a command in IPFS to update pins (`ipfs pin update #{old-cid} #{new-cid}`) which may be useful for here.

Similar to in `pins#create`, before saving the `Pin` to the database, we also set the address of our local IPFS node in the `delegates` field, fetched using `ipfs id` and then attempt to connect to each `origin` provided (`ipfs swarm connect #{origin address}`)

The spec says that a successful update results in a 202 (`:accepted`) response code with body of both the pin and it's status is then returned as JSON, rendered using the same jbuilder template as `pins#show`.

In rails the default is 200, as it appears that the spec assumes the ipfs actions will be happening in a job queue after the request has completed, although most http clients will accept and 2XX response as successful so this may not matter to much.

### Delete

DELETE request to /pins/{id} go to `pins#destroy`, just like regular CRUD rails, we look up the `Pin` by `id` (404ing if not found), unpin the `cid` on the IPFS node (`ipfs pin rm #{cid}`) and then delete the record.

Successful deletion results in a 202 (`:accepted`) response with no body.

In rails the default is 200 (204 is also standard when there is no response body), as it appears that the spec assumes the ipfs actions will be happening in a job queue after the request has completed, although most http clients will accept and 2XX response as successful so this may not matter to much.

## TODO

- integration testing for rails api controller
- basic unit tests for pins model
- `info` method on model
  - status_details
  - dag_size
  - raw_size
  - pinned_until
- queue for pinning in the background (sidekiq, recording state in `status`)
- access token authentication
- basic pinning client for testing
- only unpin cid if this is the only pin with that CID
- method for expiring pins after a certain amount of time (does it deleted it or update status?)

## Notes

- Does NOT support pinning IPNS names at the moment
- Pagination is manual for the client, no need for pagination library or headers in server
- assumes array in query params is comma seperated (cid=foo,bar)
