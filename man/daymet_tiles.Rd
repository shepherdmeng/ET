% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataDocumentation.R
\docType{data}
\name{daymet_tiles}
\alias{daymet_tiles}
\title{DAYMET Tile Index}
\format{a \code{SpatialPolygonsDataFrame}
\itemize{
\item 'TileID':  A \code{integer} Tile ID
\item 'XMin':    A \code{integer} minimum latitude
\item 'XMax':    A \code{integer} maximum latitude
\item 'YMin':    A \code{integer} minimum longitide
\item 'YMax':    A \code{integer} maximum longitude
}}
\source{
\href{https://daymet.ornl.gov/gridded.html}{DAYMET Tile Data}
}
\usage{
daymet_tiles
}
\description{
\code{daymet_tiles} contains the Polygon tile index for DAYMET meterological Data
}
\examples{
\dontrun{
 load("daymet_tiles.rda")
}
}
\keyword{datasets}
