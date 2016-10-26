# cablecuttr
An R wrapper for CanIStream.It API

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
|Netflix Instant |60031262    |     0|http://dvd.netflix.com/Movie/Love-Actually/60031262 |http://canistream.it/link/go/5237a5b1f5f807362d000000 |2016-10-24 15:34:59 |

Behind the scenes, it uses `find_movie()` to fetch the movie's ID. In case of multiple matches, it defaults to the first result. You can call it directly:

```R
find_movie("Muppets")[, c("title", "year", "movie_id")]
```

|title                                 | year|movie_id                 |
|:-------------------------------------|----:|:------------------------|
|Muppets Most Wanted                   | 2014|52c365f8f5f8070c3d01e737 |
|The Muppets                           | 2011|4eb0469bf5f807b40f000000 |
|Muppets From Space                    | 1999|4eb05831f5f807536d000004 |
|A Muppet Family Christmas             | 1987|4eb0469bf5f807b40f000001 |
|The Muppet Christmas Carol            | 1992|4eb01c45f5f807f733000003 |
|Muppet Treasure Island                | 1996|4eb011bef5f807021e000003 |
|The Muppet Movie                      | 1979|4eb0469bf5f807b40f000002 |
|The Muppets Take Manhattan            | 1984|4eb034caf5f8075a59000010 |
|The Great Muppet Caper                | 1981|4eb0603bf5f807511d000000 |
|Muppets: The Tale of the Bunny Picnic | 1992|54b7507ba3f5ec1507b6c06c |

And then pick a specific **movie_id** to give to `can_i_stream_id()`:

```R
# The Muppet Christmas Carol (1992)
can_i_stream_id("4eb01c45f5f807f733000003", "purchase")
```

|friendly_name         |external_id       | price|direct_url                                                                                                  |short_url                                             |last_checked        |
|:---------------------|:-----------------|-----:|:-----------------------------------------------------------------------------------------------------------|:-----------------------------------------------------|:-------------------|
|Apple iTunes Purchase |206329718         |  9.99|https://itunes.apple.com/us/movie/the-muppet-christmas-carol/id206329718?uo=4&at=10lcsB                     |http://canistream.it/link/go/509f1c78f5f807032b000000 |2016-10-25 12:32:07 |
|Google Play Purchase  |movie-VDFltsFgShc |  9.99|https://play.google.com/store/movies/details/The_Muppet_Christmas_Carol?id=VDFltsFgShc&PAffiliateID=100l3vd |http://canistream.it/link/go/50802738f5f807e648000002 |2016-10-25 12:31:53 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/bearloga/cablecuttr/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

