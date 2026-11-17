library(httptest2)

# Mocked tests replay recorded fixtures and need no real credentials, so a dummy
# token is used by default.
#
# To re-record fixtures, delete the relevant mock directory and set
# RAIRTABLE_RECORD_PAT to a personal access token scoped to the test base only.
# Never record with a token that can see other bases: the base listing
# (meta/bases.json) is saved in the fixtures.
withr::local_envvar(
  AIRTABLE_PAT = Sys.getenv("RAIRTABLE_RECORD_PAT", unset = "test_pat"),
  .local_envir = teardown_env()
)
