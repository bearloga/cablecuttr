#' @title Search for movies by title
#' @description You can use this to find the exact ID of the movie you are
#'   interested in, in case there are multiple remakes or if you only know
#'   a part of the movie's title.
#' @details The API is a bit slow/unreliable, so if you get a HTTP 504 error,
#'   just re-run the call.
#' @param movie_name The title of the movie to search for
#' @param user_agent Allows specification of custom UA
#' @examples
#' \dontrun{
#'   find_movie("Love Actually")
#' }
#' @return A data.frame of search results with the following columns:
#' \describe{
#'   \item{movie_id}{The movie's ID}
#'   \item{title}{The movie's title}
#'   \item{year}{The movie's year}
#'   \item{description}{The movie's description}
#'   \item{rating}{The movie's rating}
#'   \item{mpaa_rating}{The movie's rating by Motion Pictures Association of America}
#'   \item{duration}{The duration of the movie (in minutes)}
#'   \item{image}{The url of the movie art}
#'   \item{image_last_checked}{A datetime the movie art was last checked for}
#'   \item{url_canistreamit}{The movie's page on \href{http://www.canistream.it/}{CanIStream.It}}
#'   \item{url_rottentomatoes}{The movie's page on \href{https://www.rottentomatoes.com/}{Rotten Tomatoes}}
#'   \item{url_imdb}{The movie's page on \href{http://www.imdb.com/}{IMDB}},
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
  if (httr::http_error(response)) {
    stop(
      sprintf(
        'CanIStream.It API request for "%s" failed (%s)\n%s',
        movie_name, httr::status_code(response), httr::http_status(response)
      ),
      call. = FALSE
    )
  }
  if (httr::http_type(response) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  response_json <- httr::content(response, "text", type = "application/json", encoding = "UTF-8")
  response_content <- jsonlite::fromJSON(response_json, simplifyDataFrame = FALSE)
  if (length(response_content) == 0) {
    return(empty_movies())
  }
  foo <- function(x) {
    if (is.null(x)) {
      return(NA)
    } else if (x == "") {
      return(NA)
    } else {
      return(x)
    }
  }
  result <- do.call(rbind, lapply(response_content, function(item) {
    return(data.frame(
      movie_id = foo(item$`_id`),
      title = foo(item$title),
      year = foo(item$year),
      description = foo(item$description),
      rating = foo(item$rating),
      mpaa_rating = foo(item$mpaa_rating),
      duration = foo(item$duration),
      image = foo(item$image),
      image_last_checked = foo(item$image_last_updated),
      url_rottentomatoes = foo(item$links$rottentomatoes),
      url_imdb = foo(item$links$imdb),
      url_canistreamit = foo(item$links$shortUrl),
      stringsAsFactors = FALSE
    ))
  }))
  result$year <- as.numeric(result$year)
  result$image[result$image == "http://www.canistream.it/img/missing-poster.jpg"] <- NA
  result$rating[result$rating < 0] <- NA
  result$image_last_checked <- as.POSIXct(result$image_last_checked, origin = "1970-01-01")
  return(result)
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
#' can_i_stream_id("4eb0173df5f8079d29000002", "purchase")
#' \dontrun{
#'   movie_id <- find_movie("The Babadook")$movie_id
#'   can_i_stream_id(movie_id, "streaming")
#' }
#' @describeIn can_i_stream Query CanIStream.It by movie ID and media type
#' @export
can_i_stream_id <- function(movie_id, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL, offline = FALSE) {
  if (!media_type[1] %in% c("streaming", "rental", "purchase", "dvd", "xfinity")) {
    stop("Unacceptable media type")
  }
  if (length(movie_id) > 1) {
    warning("Cannot process more than one movie ID. Looking up just the first one...")
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
  if (httr::http_error(response)) {
    stop(
      sprintf(
        "CanIStream.It API request for movie #%s failed (%s)\n%s",
        movie_id, httr::status_code(response), httr::http_status(response)
      ),
      call. = FALSE
    )
  }
  if (httr::http_type(response) != "application/json") {
    stop("API did not return JSON", call. = FALSE)
  }
  response_json <- httr::content(response, "text", type = "application/json", encoding = "UTF-8")
  response_content <- jsonlite::fromJSON(response_json, simplifyVector = FALSE)
  if (length(response_content) == 0) {
    message("Movie #", movie_id, " is not available via ", media_type[1])
    return(empty_services())
  }
  foo <- function(x) {
    if (is.null(x)) {
      return(NA)
    } else if (x == "") {
      return(NA)
    } else {
      return(x)
    }
  }
  results <- do.call(rbind, lapply(response_content, function(item) {
    return(data.frame(
      friendly_name = foo(item$friendlyName),
      external_id = foo(item$external_id),
      price = foo(item$price),
      direct_url = foo(item$direct_url),
      short_url = foo(item$url),
      last_checked = foo(item$date_checked),
      stringsAsFactors = FALSE
    ))
  }))
  rownames(results) <- NULL
  results$last_checked <- as.POSIXct(results$last_checked, origin = "1970-01-01")
  return(results)
}

#' @examples
#' \dontrun{
#'   can_i_stream_it("Tinker Tailor Soldier Spy")
#' }
#' @describeIn can_i_stream Query CanIStream.It by movie name and media type
#' @export
can_i_stream_it <- function(movie_name, media_type = c("streaming", "rental", "purchase", "dvd", "xfinity"), user_agent = NULL) {
  if (!media_type[1] %in% c("streaming", "rental", "purchase", "dvd", "xfinity")) {
    stop("Unacceptable media type")
  }
  movies <- find_movie(movie_name)
  if (nrow(movies) == 0) {
    warning('Could not find any movies matching "', movie_name, '"')
    return(empty_services())
  } else if (nrow(movies) > 1) {
    message('Found more than one movie matching "', movie_name, '"')
    message("Defaulting to first result: ", movies$title[1], " (", movies$year[1], ") - #", movies$movie_id[1],"")
    message('Use find_movie("', movie_name, '") with can_i_stream_id() to be exact')
  } else {
    message('Found a movie matching "', movie_name, '": ', movies$title[1], " (", movies$year[1], ")")
  }
  return(can_i_stream_id(movies$movie_id[1], media_type))
}
