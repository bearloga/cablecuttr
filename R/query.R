#' @title Search for movies by title
#' @description You can use this to find the exact ID of the movie you are
#'   interested in, in case there are multiple remakes or if you only know
#'   a part of the movie's title.
#' @details The API is a bit slow/unreliable, so if you get a HTTP 504 error,
#'   just re-run the call.
#' @param movie_name The title of the movie to search for
#' @param user_agent Allows specification of custom UA
#' @param offline A logical flag to simulate the API request
#' @examples
#' # Use a saved JSON response for 'Groundhog Day'
#' find_movie("Groundhog Day", offline = TRUE)
#' \dontrun{
#'   find_movie("Finding Nemo")
#' }
#' @return A data.frame of search results with the following columns:
#' \describe{
#'   \item{title}{The movie's title}
#'   \item{movie_id}{The movie's ID}
#'   \item{description}{The movie's description}
#'   \item{rating}{The movie's rating}
#'   \item{image}{The url of the movie art}
#'   \item{image_last_checked}{A datetime the movie art was last checked for}
#'   \item{url_canistreamit}{The movie's page on \href{http://www.canistream.it/}{CanIStream.It}}
#'   \item{url_rottentomatoes}{The movie's page on \href{https://www.rottentomatoes.com/}{Rotten Tomatoes}}
#'   \item{url_imdb}{The movie's page on \href{http://www.imdb.com/}{IMDB}}
#' }
#' @export
find_movie <- function(movie_name, user_agent = NULL, offline = FALSE) {
  if (offline) {
    response <- offline_example("movies")
    result <- as.data.frame(jsonlite::fromJSON(response, simplifyDataFrame = TRUE, flatten = TRUE))
  } else {
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
    if (httr::http_type(response) != "application/json") {
      stop("API did not return json", call. = FALSE)
    }
    if (httr::http_error(response)) {
      stop(
        sprintf(
          "CanIStream.It API request failed (%s)\n%s",
          httr::status_code(response),
          httr::http_status(response)
        ),
        call. = FALSE
      )
    }
    result <- as.data.frame(jsonlite::fromJSON(httr::content(response, "text", type = "application/json", encoding = "UTF-8"), simplifyDataFrame = TRUE, flatten = TRUE))
  }
  if (nrow(result) == 0) {
    return(empty_movies())
  }
  names(result) <- c("actors", "rating", "year", "description", "title", "movie_id", "image", "image_last_checked", "url_rottentomatoes", "url_imdb", "url_canistreamit")
  result$image[result$image == "http://www.canistream.it/img/missing-poster.jpg"] <- NA
  result$rating[result$rating < 0] <- NA
  result$image_last_checked <- as.POSIXct(result$image_last_checked, origin = "1970-01-01")
  return(result[, c("title", "year", "movie_id", "description", "rating", "image", "image_last_checked", "url_canistreamit", "url_rottentomatoes", "url_imdb")])
}

#' @title Query CanIStream.It
#' @description Searches for the movie's availability on various online
#'   services/stores.
#' @details The API is a bit slow/unreliable, so if you get a HTTP 504 error,
#'   just re-run the call.
#' @param movie_id The movie's ID, found by running \code{\link{find_movie}}
#' @param movie_name The movie's name, which will be passed to
#'   \code{\link{find_movie}}
#' @param media_type The type to search for: \describe{
#'   \item{streaming}{Subscription based and free instant streaming services.}
#'   \item{rental}{Services that offer time limited rentals (24-48 hours) for a small fee.}
#'   \item{purchase}{Services that offer the ability to purchase a movie forever.}
#'   \item{dvd}{Services that allow you to purchase or rent a physical dvd/blu-ray disc.}
#'   \item{xfinity}{Cable Subscription services with online viewing brought to you by Xfinity.}
#' }
#' @param user_agent Allows specification of custom UA
#' @param offline A logical flag to simulate the API request
#' @name can_i_stream
NULL

#' @return A data.frame with a row for each service/store and the following
#'   columns: \describe{
#'     \item{friendly_name}{The name of the service/store}
#'     \item{external_id}{The ID of the movie/show}
#'     \item{price}{The movie's price on the service/store}
#'     \item{direct_url}{The URL of the movie on the service/store}
#'     \item{short_url}{The CanIStream.It URL that redirects to service/store}
#'     \item{last_checked}{The datetime the service was last checked}
#'   }
#' @examples
#'
#' # Use a saved JSON response for 'Groundhog Day'
#' can_i_stream_id("4eb0173df5f8079d29000002", "purchase", offline = TRUE)
#'
#' \dontrun{
#'   movie_id <- find_movie("The Babadook")$movie_id
#'   can_i_stream_id(movie_id, "streaming")
#' }
#' @describeIn can_i_stream Query CanIStream.It by movie ID and media type
#' @export
can_i_stream_id <- function(movie_id, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL, offline = FALSE) {
  if (!media_type[1] %in% c("streaming", "rental", "purchase", "dvd", "xfinity")) {
    stop("unacceptable media type")
  }
  if (length(movie_id) > 1) {
    warning("Cannot process more than one movie ID. Looking up just the first one.")
    movie_id <- movie_id[1]
  }
  if (offline) {
    response <- offline_example("services")
    results <- jsonlite::fromJSON(response, simplifyVector = FALSE)
  } else {
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
    if (httr::http_type(response) != "application/json") {
      stop("API did not return json", call. = FALSE)
    }
    if (httr::http_error(response)) {
      stop(
        sprintf(
          "CanIStream.It API request failed (%s)\n%s",
          httr::status_code(response),
          httr::http_status(response)
        ),
        call. = FALSE
      )
    }
    results <- jsonlite::fromJSON(httr::content(response, "text", type = "application/json", encoding = "UTF-8"), simplifyVector = FALSE)
  }
  if (length(results) == 0) {
    message("Movie #", movie_id, " is not available via ", media_type[1], ".")
    return(empty_services())
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

#' @examples
#' # Use a saved JSON response for 'Groundhog Day'
#' can_i_stream_it("Groundhog Day", "purchase", offline = TRUE)
#' \dontrun{
#'   can_i_stream_it("A Girl Walks Home Alone At Night")
#' }
#' @describeIn can_i_stream Query CanIStream.It by movie name and media type
#' @export
can_i_stream_it <- function(movie_name, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL, offline = FALSE) {
  if (!media_type[1] %in% c("streaming", "rental", "purchase", "dvd", "xfinity")) {
    stop("unacceptable media type")
  }
  movies <- find_movie(movie_name, offline = offline)
  if (nrow(movies) == 0) {
    warning("Could not find the ID of the movie '", movie_name, "'")
    return(empty_services())
  } else if (nrow(movies) > 1) {
    message("Found more than one movie matching '", movie_name, "'")
    message("Defaulting to first result: ", movies$title[1], " (", movies$year[1], ") [", movies$movie_id[1],"]")
  } else {
    message("Found a movie matching '", movie_name, "': ", movies$title[1], " (", movies$year[1], ")")
  }
  return(can_i_stream_id(movies$movie_id[1], media_type, offline = offline))
}
