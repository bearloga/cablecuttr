empty_movies <- function() {
  return(
    data.frame(
      "title" = character(),
      "year" = numeric(),
      "movie_id" = character(),
      "description" = character(),
      "rating" = numeric(),
      "image" = character(),
      "image_last_checked" = as.POSIXct(numeric(), origin = "1970-01-01"),
      "url_canistreamit" = character(),
      "url_rottentomatoes" = character(),
      "url_imdb" = character()
    )
  )
}

empty_services <- function() {

}
