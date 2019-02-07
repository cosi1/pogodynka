httr::set_config(httr::config(ssl_verifypeer = 0L))

# Get Meteo.pl API key from a local file
get_api_key = function(file = "api_key.txt") {
  readLines(con = file, warn = FALSE)
}

# Query Meteo.pl API
query_api = function(endpoint,
                     headers,
                     api_key,
                     model = "coamps",
                     grid = "2a") {
  
  url = sprintf(
    "https://api.meteo.pl/api/v1/model/%s/grid/%s/%s",
    model, grid, endpoint
  )
  headers = httr::add_headers(
    Authorization = paste("Token", api_key)
  )
  httr::content(httr::stop_for_status(httr::POST(url, headers)))
}

# Convert latitude/longitude to grid coordinates
decode_coords = function(api_key, lat, lng) {
  endpoint = sprintf("latlon2rowcol/%s,%s", lat, lng)
  data = query_api(endpoint = endpoint, api_key = api_key)
  unlist(data$points)
}

# Get forecast data
get_meteo = function(lng,
                     lat,
                     date,
                     api_key,
                     field = "airtmp_pre_fcstfld",
                     level = "000010_000000") {
  
  coords = decode_coords(api_key = api_key, lat = lat, lng = lng)
  
  endpoint = sprintf(
    "coordinates/%d,%d/field/%s/level/%s/date/%s/forecast/",
    coords[1], coords[2], field, level, date
  )
  data = query_api(endpoint = endpoint, api_key = api_key)
  data$times = parsedate::parse_iso_8601(unlist(data$times))
  data$data = unlist(data$data)
  as.data.frame(data)
}

# Dump diagnostic message in JSON format to stderr
dump_log = function(...) {
  message(jsonlite::toJSON(list(...), auto_unbox = TRUE))
}
