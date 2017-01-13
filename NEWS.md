cablecuttr 0.1.1
----------------

* Fixes [Issue 4](https://github.com/bearloga/cablecuttr/issues/4)
   - CanIStream.It changed their API, which broke the old way of converting JSON to data.frames
   - This new version should be more resilient to any future changes

cablecuttr 0.1.0
----------------

*  Initial CRAN release with functions to:
   - Find a movie's ID (`find_movie`)
   - Look up its availability (`can_i_stream_i[d|t]`)
