% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lsSearch.R
\name{lsSearch}
\alias{lsSearch}
\title{Search Landsat 7-8 images using EarthExplorer API}
\usage{
lsSearch(
  product,
  startDate,
  endDate,
  region,
  username,
  password,
  dates,
  logout = TRUE,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{product}{the name of the dataset. Avaliable names saved in `RGISTools'
(\code{getRGISToolsOpt("EE.DataSets")}).}

\item{startDate}{a \code{Date} class object with the starting date of the 
study period. This argument is mandatory if 
  \code{dates} is not defined.}

\item{endDate}{a \code{Date} class object with the ending date of the 
study period. This argument is mandatory if 
  \code{dates} is not defined.}

\item{region}{a \code{Spatial*}, projected \code{raster*}, o
r \code{sf} class object defining the area of interest. This argument is
mandatory if \code{pathrow}, \code{extent}, or \code{lonlat} are not defined.}

\item{username}{NASA’s `EarthData' username.}

\item{password}{NASA’s `EarthData' password.}

\item{dates}{a vector with the capturing dates being searched. This
argument is mandatory if \code{startDate} and \code{endDate} are not defined.}

\item{logout}{logical argument. If \code{TRUE}, logges out from EarthExplorer
API}

\item{verbose}{logical argument. If \code{TRUE}, the function prints the 
running steps and warnings.}

\item{...}{arguments for nested functions:
 \itemize{
  \item \code{pathrow} a list of vectors with the path and row numbers of
  the tiles concerning the region of interest. This argument is mandatory
  if \code{region}, \code{extent} or \code{lonlat} are not provided. Ex. 
  \code{list(c(200,31),c(200,30))}.
  \item \code{lonlat} a vector with the longitude/latitude (EPSG:4326)
  coordinates of the point of interest. Ex. \code{c(-1.64323,42.81687)}.
  This argument is mandatory if \code{region}, \code{pathrow}, or \code{lonlat}
  are not defined.
  \item \code{extent} an \code{extent}, \code{Raster*}, or 
  \code{Spatial*} object representing the region of interest with 
  longitude/latitude (EPSG:4326) coordinates. This argument is mandatory if 
  \code{region}, \code{pathrow} or \code{lonlat} are not defined.
  
}}
}
\value{
a \code{data.frame} with the name of the images and their metadata.
}
\description{
\code{lsSearch} searches Landsat 7-8 images in the EarthExplorer API concerning
a particular location and date interval. The function returns a 
\code{data.frame} with the names of the images and their metadata.
}
\examples{
\dontrun{
# search by path and row numbers of a tile
getRGISToolsOpt("EE.DataSets")
sres <- lsSearch(product = "LANDSAT_8_C1",
                 startDate = as.Date("01-01-2011", "\%d-\%m-\%Y"),
                 endDate = as.Date("31-12-2013", "\%d-\%m-\%Y"),
                 username = "username",
                 password = "password",
                 region = ex.navarre,
                 pathrow = list(c(200,31),c(200,30)))
                 
sres <- lsSearch(product = "LANDSAT_8_C1",
                 startDate = as.Date("01-01-2011", "\%d-\%m-\%Y"),
                 endDate = as.Date("31-12-2013", "\%d-\%m-\%Y"),
                 username = "username",
                 password = "password",
                 lonlat = c(-1.64323,42.81687))
                                   
                  
# search by extent (long/lat coordinates)
# load a spatial polygon object of Navarre
data(ex.navarre)
sres <- lsSearch(product = "LANDSAT_8_C1",
                 startDate = as.Date("01-01-2011", "\%d-\%m-\%Y"),
                 endDate = as.Date("31-12-2013", "\%d-\%m-\%Y"),
                 username = "username",
                 password = "password",
                 extent = ex.navarre)
}
}
