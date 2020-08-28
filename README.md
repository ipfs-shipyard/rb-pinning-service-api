# IPFS Pinning Service API

A rails app that implements the [IPFS Pinning Service API](https://ipfs.github.io/pinning-services-api-spec/).

## Endpoints

The CRUD design of the pinning service API spec maps nicely onto the standard rails restful routing design with only a few minor tweaks needed to implement the full spec.

For the API, the default format is set to `:json` rather than HTML and CSRF protection is disabled, we've also nested the API routes under /api/v1 to seperate it from any html pages and allow deploying a v2 in the future without breaking compatibility with existing v1 clients.

TODO: implement authentication and access control via `Authorization: Bearer <access-token>`

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

The response of both the pin and it's status is then returned as JSON, rendered using the same jbuilder template as #show.

### List

GET request to /pins go to `pins#index` with optional url query params to filter responses. Default of 10 records per page (max `1000`), always ordered by newest first (`created_at DESC`).

Pagination is not the usual `?page=1` but instead the client is expected to work out the next page by passing the `created` field of the last record in a response as `before`, so order must always be the by creation date for pagination to work. (An alternative option here would be `offset` which would allow pagination and ordering at the same time).

`status` can be one or more of the four allowed statuses (`queued`, `pinning`, `pinned`, `failed`), comma separated and if `status` is not provided (or invalid), then it defaults to `pinned`, this are passed straight to ActiveRecord to filter on: `where(status: statuses)`.

One or more CID can be optionally passed, comma separated to `cid`, as they are case sensitive we can pass the array directly to ActiveRecord to filter on: `where(cid: cids)`.

Clients can optionally filter results by `name`, which can be an exact or partial match, the spec is not clear on case sensitivity but we use a case insensitive `like` query in postgresql: `where('name ilike ?', "%#{name}%")`.

Clients can optionally filter results by a key+value pair from the `meta` field, which is provided as json in the query parameter. Because we store `meta` in a `jsonb` field in postgresql, we can use the provided SQL function: `where("meta->>? = ?", meta.key, meta.value)`. The spec is not clear on if the JSON stored in `meta` can be nested, we allow nested JSON to be stored on creation but the query may not work as expected if nested JSON is passed when filtering.

`before` and `after` allow optional filtering by `created_at`, we can pass the date through to postgresql: `where('created_at < ?', before)` and `where('created_at > ?', after)` if present.

`count` is the total number of records available for the given filters, ignoring the `limit` we we make a separate SQL query for that before loading the limited `Pin` records, if `count` is zero we can skip the second SQL query and return an empty array.

### Get

### Modify

### Delete

## TODO

- `info` method on model
  - status_details
  - dag_size
  - raw_size
  - pinned_until
- queue for pinning in the background (sidekiq, recording state in `status`)
- access token authentication
- basic pinning client for testing
- only unpin cid if this is the only pin with that CID

## Notes

- Does NOT support pinning IPNS names at the moment
- Pagination is manual for the client, no need for pagination library or headers in server
- assumes array in query params is comma seperated (cid=foo,bar)
