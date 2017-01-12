# cablecuttr
An R wrapper for CanIStream.It API

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/cablecuttr)](https://cran.r-project.org/package=cablecuttr)
[![CRAN Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/cablecuttr)](https://cran.rstudio.com/web/packages/cablecuttr/index.html)

[CanIStream.It](http://www.canistream.it/) is a free service created by [Urban Pixels](http://www.urbanpixels.com/) that allows you to search across the most popular streaming, rental, and purchase services to find where a movie is available.

## Installation

```R
install.packages("cablecuttr")
```

To use the development version:

```R
if ( !('devtools' %in% installed.packages()) ) install.packages("devtools")

devtools::install_github("bearloga/cablecuttr")
```

## Usage

You can look up streaming/rental/purchase/etc. options for a movie by using `can_i_stream_it()`, which requires the movie's title and the media type:

```R
can_i_stream_it("Love Actually", "streaming")
# Found more than one movie matching 'Love Actually'
# Defaulting to first result: Love Actually (2003) [4e79a720f5f8071e7e000000]
```

|friendly_name   |external_id | price|direct_url                                          |short_url                                             |last_checked        |
|:---------------|:-----------|-----:|:---------------------------------------------------|:-----------------------------------------------------|:-------------------|
|Netflix Instant |60031262    |     0|http://dvd.netflix.com/Movie/Love-Actually/60031262 |http://canistream.it/link/go/5237a5b1f5f807362d000000 |2017-01-12 15:24:57 |

Behind the scenes, it uses `find_movie()` to fetch the movie's ID. In case of multiple matches, it defaults to the first result. You can call it directly:

```R
find_movie("Toy Story")[, c("title", "year", "movie_id")]
```

|title                      | year|movie_id                 |
|:--------------------------|----:|:------------------------|
|Toy Story                  | 1995|4eb04731f5f807d30f000012 |
|Toy Story 2                | 1999|4eb04731f5f807d30f000011 |
|Toy Story of Terror!       | 2013|52507c01f5f807682d000004 |
|Toy Story of Terror!       | 2013|52768d6951cf33b20f73791c |
|Toy Story That Time Forgot | 2014|5474f881a3f5ec3f71b6c06b |
|Toy Story 3                | 2010|4eb044b8f5f807167c00000e |
|A Syrian Love Story        | 2015|55f8a7d2f5f807cd2cbb379f |

And then pick a specific **movie_id** to give to `can_i_stream_id()`:

```R
# Toy Story (1995)
can_i_stream_id("4eb04731f5f807d30f000012", "rental")
```

|friendly_name       |external_id       |price |direct_url                                                                                 |short_url                                             |last_checked        |
|:-------------------|:-----------------|:-----|:------------------------------------------------------------------------------------------|:-----------------------------------------------------|:-------------------|
|Amazon Video Rental |B005ZMV2EQ        |2.99  |https://www.amazon.com/Toy-Story-Tim-Allen/dp/B005ZMV2EQ                                   |http://canistream.it/link/go/4f1f34a7f5f807dd3d000023 |2017-01-12 11:38:23 |
|Apple iTunes Rental |188703840         |2.99  |https://itunes.apple.com/us/movie/toy-story/id188703840?uo=4&at=10lcsB                     |http://canistream.it/link/go/4f1f34a8f5f807dd3d000024 |2017-01-12 11:38:25 |
|Youtube Rental      |c3986gGp3Qs       |2.99  |https://www.youtube.com/watch?v=c3986gGp3Qs                                                |http://canistream.it/link/go/4f1b791cf5f807e74f000026 |2017-01-12 11:38:24 |
|Google Play Rental  |movie-c3986gGp3Qs |2.99  |https://play.google.com/store/movies/details/Toy_Story?id=c3986gGp3Qs&PAffiliateID=100l3vd |http://canistream.it/link/go/4f47f373f5f807665b000015 |2017-01-12 11:38:24 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/cablecuttr/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

