empty_movies <- function() {
  return(
    data.frame(
      "movie_id" = character(),
      "title" = character(),
      "year" = numeric(),
      "description" = character(),
      "rating" = numeric(),
      "mpaa_rating" = character(),
      "duration" = numeric(),
      "image" = character(),
      "image_last_checked" = as.POSIXct(numeric(), origin = "1970-01-01"),
      "url_canistreamit" = character(),
      "url_rottentomatoes" = character(),
      "url_imdb" = character(),
      stringsAsFactors = FALSE
    )
  )
}

empty_services <- function() {
  return(
    data.frame(
      friendly_name = character(),
      external_id = character(),
      price = numeric(),
      direct_url = character(),
      short_url = character(),
      last_checked = as.POSIXct(character(), origin = "1970-01-01"),
      stringsAsFactors = FALSE
    )
  )
}
