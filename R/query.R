#' @title Search for movies by title
#' @param movie_name The title of the movie to search for
#' @param user_agent Allows specification of custom UA
#' @example find_movie("Groundhog Day")
#' @return A data.frame
#' \describe{
#'   \item{One}{First item}
#'   \item{Two}{Second item}
#' }
#' @export
find_movie <- function(movie_name, user_agent = NULL) {
  if (is.null(user_agent)) {
    user_agent <- "cablecuttr R client: https://github.com/bearloga/cablecuttr"
  }
  response <- httr::GET(
    "http://www.canistream.it/",
    path = "services/search",
    query = list(
      "movieName" = movie_name
    ),
    httr::user_agent(user_agent)
  )
  httr::stop_for_status(response)
  if (!httr::status_code(response) %in% c("200", "304")) {
    result <- as.data.frame(jsonlite::fromJSON(httr::content(response, "text", type = "application/json", encoding = "UTF-8"), simplifyDataFrame = TRUE, flatten = TRUE))
    names(result) <- c("actors", "rating", "year", "description", "title", "movie_id", "image", "image_last_checked", "url_rottentomatoes", "url_imdb", "url_canistreamit")
    result$image[result$image == "http://www.canistream.it/img/missing-poster.jpg"] <- NA
    result$rating[result$rating < 0] <- NA
    result$image_last_checked <- as.POSIXct(result$image_last_checked, origin = "1970-01-01")
    return(result[, c("title", "year", "movie_id", "description", "rating", "image", "image_last_checked", "url_canistreamit", "url_rottentomatoes", "url_imdb")])
  } else {
    return(empty_movies())
  }
}

#' @title Query CanIStream.It by movie name (or ID) and media type
#' @param movie_id The movie's ID, found by \code{\link{find_movie_id}}
#' @param media_type The type to search for...
#' @param user_agent Allows specification of custom UA
#' @return A data.frame with a row for each service/store and the following
#'   columns: \describe{
#'     \item{friendly_name}{The name of the service/store.}
#'     \item{external_id}{The ID of the movie/show}
#'     \item{price}{Second item}
#'     \item{direct_url}{Second item}
#'     \item{short_url}{Second item}
#'     \item{last_checked}{Second item}
#'   }
#' @example
#' movie_id <- find_movie("The Babadook")$movie_id
#' can_i_stream_id(movie_id, "streaming")
#' @export
can_i_stream_id <- function(movie_id, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL) {
  if (!media_type[1] %in% c("streaming", "rental", "purchase", "dvd", "xfinity")) {
    stop("unacceptable media type")
  }
  if (length(movie_id) > 1) {
    warning("Cannot process more than one movie ID. Looking up just the first one.")
    movie_id <- movie_id[1]
  }
  if (is.null(user_agent)) {
    user_agent <- "cablecuttr R client: https://github.com/bearloga/cablecuttr"
  }
  response <- httr::GET(
    "http://www.canistream.it/",
    path = "services/query",
    query = list(
      "movieId" = movie_id,
      "attributes" = "1",
      "mediaType" = media_type[1]
    ),
    httr::user_agent(user_agent)
  )
  httr::stop_for_status(response)
  results <- jsonlite::fromJSON(httr::content(response, "text", type = "application/json", encoding = "UTF-8"), simplifyVector = FALSE)
  if (length(results) == 0) {
    message("Movie #", movie_id, " is not available via ", media_type[1], ".")
  }
  output <- do.call(rbind, lapply(results, function(result) {
    return(
      data.frame(
        friendly_name = result$friendlyName,
        external_id = ifelse("external_id" %in% names(result), result$external_id, NA),
        price = as.numeric(ifelse("price" %in% names(result), result$price, NA)),
        direct_url = ifelse("direct_url" %in% names(result), result$direct_url, NA),
        short_url = ifelse("url" %in% names(result), result$url, NA),
        last_checked = as.POSIXct(ifelse("date_checked" %in% names(result), result$date_checked, NA), origin = "1970-01-01"),
        stringsAsFactors = FALSE
      )
    )
  }))
  rownames(output) <- NULL
  return(output)
}

#' @export
can_i_stream_it <- function(movie_name, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL) {
  movies <- find_movie(movie_name)
  if (nrow(movie_id) == 0) {
    warning("Could not find the ID of the movie '", movie_name, "'")
    return(empty_services())
  }
  return(can_i_stream_id(movies$movie_id[1], media_type))
}
