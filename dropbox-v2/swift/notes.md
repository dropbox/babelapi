### 12/8/2014

- Inconsistent representation of account information makes it awkward to serialize objects from response. When fetching /users/info/me, the response is different than when fetching /users/info. When fetching /users/info, the response format is different depending on what relationship that user has with you.
- It's weird that /users/info/me requires an empty JSON object and `Content-Type: application/json`, even though no sender information is being communicated.
- After working with the API a bit, I have to admit that the lack of REST conventions still feels weird. I find myself making mistakes and guessing wrong with nearly every endpoint that I integrate. I get squeamish when everything is a POST. It's a matter of personal preference, but one that I would expect to be shared with many experienced developers.
- Concepts like structure inheritance, unions, and enums make for an elegant abstraction, but for something as menial as shuttling data, redundancy is a virtue. The abstractions should sit on the client application layer, not the transport layer.
- Overall, the project of Babel is laudable, and has noble ambitions. In many ways, HTTP & REST + JSON have stunted the growth of programmable web technologies, and caused massive amounts of busy work for implementors on both client and server-side. Those of us who have been doing this song and dance number too many times to count (since, heck, Rails 2.0 popularized all of this some 6 years back), the thought of solving everything once and for all has definite appeal. However, the sustained popularity and ubiquity of REST & JSON is something that can't be ignored for an API suited for developers today. The peril of designing a one-size-fits-all solution is that it ends up being lousy for every use case. I worry that the RPC-centric philosophy of Babel does not align well with HTTP, which will likely be the primary—if not sole—use case.
- I would almost prefer for Babel to drop HTTP + JSON as the primary use case and just use Protobufs or some standardized RPC mechanism exclusively.
- The folks at Heroku have spent a long, long time chipping at this problem. Their v3 API was something in progress when I started, and was only just being shipped when I left a few years later. I think the end result of their thinking could offer a great deal of insight—if not be suitable for Dropbox API v2. (see: https://bgentry.io/blog/2014/01/09/auto-generating-a-go-api-client-for-heroku)
- tl;dr I usually have a lot of fun writing native language API clients, but working with v2 was not enjoyable. A lot of that could be due to everything being a work-in-progress, but I worry that it's something more fundamental.

### 11/21/2014

- Reserved keywords, like `private`, must be backtick-escaped.
- Struct fields are `snake_cased`, but must be `llamaCased`
- Documentation should be specific about `country` being ISO 3166-1 codes
- Documentation should be clear about use of ISO 639 language code or IETF / BCP 47 language tags for `locale`
- Documentation for UploadAppend route is duplicate of UploadStart
- Uncertain whether Babel should specify URL type, and if Swift implementation should type as `NSURL`.
- Typed errors feel incomplete. Conventional pattern would be to use HTTP status codes as sufficient indication of type of failure, with error messages (localized from `Accept-Language` header) for end-user. Babel specification enumerates possible error types, but as a consequence of being protocol-agnostic, does not clarify how an implementor might interpret results an actual server response.
- Previously-discussed pattern of enumerated routes has benefit of encoding API contracts independent of communication protocol. The emergent pattern, therefore, would be to generate data structures and routes from specification, followed by extensions for JSON / XML / etc. serialization and REST / RPC / etc. protocol.
- Looking for way to resolve semantic conflation between data structures used in responses and those sent as request parameters. In Swift, it's more conventional to represent small groupings of associated data in that tuple rather than a separate structure. (i.e. `case Download(path: String, rev: String)` rather than `case Download(FileTarget)`).
- Swift doesn't have a direct correspondence to `union`, but an `enum` can fill that role using associated values for each case. The trick is figuring out how to consistently generate this computationally.
