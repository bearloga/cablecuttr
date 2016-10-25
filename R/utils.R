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

offline_example <- function(type) {
  switch(
    type,
    movies = return('[{"actors":"Bill Murray, Andie MacDowell, Chris Elliott","rating":4.8,"year":1993,"description":"","title":"Groundhog Day","_id":"4eb0173df5f8079d29000002","image":"http://image.tmdb.orgtpw342vXjVd0Vu0MXRZnga7wEnHIIhO5B.jpg","image_last_updated":1476199602,"links":{"rottentomatoes":"http://www.rottentomatoes.commgroundhog_day","imdb":"http://www.imdb.comtitlett0107048","shortUrl":"http://www.canistream.itsearchmovie4eb0173df5f8079d29000002groundhog-day"}}]'),
    services = return('{\"apple_itunes_purchase\":{\"url\":\"http:\\/\\/canistream.it\\/link\\/go\\/4f24ac8ff5f807422000005a\",\"price\":9.99,\"external_id\":270870214,\"date_checked\":1477372454,\"direct_url\":\"https:\\/\\/itunes.apple.com\\/us\\/movie\\/groundhog-day\\/id270870214?uo=4&at=10lcsB\",\"time\":0,\"friendlyName\":\"Apple iTunes Purchase\",\"cache\":true},\"android_purchase\":{\"url\":\"http:\\/\\/canistream.it\\/link\\/go\\/5082f09df5f8075d3e00001d\",\"price\":9.99,\"external_id\":\"movie-8skEQx5w8Cs\",\"date_checked\":1477417898,\"direct_url\":\"https:\\/\\/play.google.com\\/store\\/movies\\/details\\/Groundhog_Day?id=8skEQx5w8Cs&PAffiliateID=100l3vd\",\"time\":0,\"friendlyName\":\"Google Play Purchase\",\"cache\":true}}')
  )
}
