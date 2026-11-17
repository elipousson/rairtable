structure(
  list(
    method = "GET",
    url = "https://api.airtable.com/v0/appu39z5mdXIsevUX/tbl0MzEDRrELyD57V?view=viwtQYeduYs7pvuwF&cellFormat=json",
    status_code = 403L,
    headers = structure(
      list(
        date = "Tue, 04 Jul 2023 19:20:17 GMT",
        `content-type` = "application/json; charset=utf-8",
        `content-length` = "251",
        `set-cookie` = "REDACTED",
        `set-cookie` = "REDACTED",
        server = "Tengine",
        `set-cookie` = "REDACTED",
        `strict-transport-security` = "max-age=31536000; includeSubDomains; preload",
        `access-control-allow-origin` = "*",
        `access-control-allow-methods` = "DELETE,GET,OPTIONS,PATCH,POST,PUT",
        `access-control-allow-headers` = "authorization,content-length,content-type,user-agent,x-airtable-application-id,x-airtable-user-agent,x-api-version,x-requested-with",
        `x-frame-options` = "DENY",
        `x-content-type-options` = "nosniff",
        etag = "W/\"fb-E5+5oHBiiIUbRT5O+8F5CtGpkBQ\"",
        vary = "Accept-Encoding"
      ),
      class = "httr2_headers"
    ),
    body = charToRaw(
      "{\"error\":{\"type\":\"INVALID_PERMISSIONS_OR_MODEL_NOT_FOUND\",\"message\":\"Invalid permissions, or the requested model was not found. Check that both your user and your token have the required permissions, and that the model names and/or ids are correct.\"}}"
    )
  ),
  class = "httr2_response"
)
