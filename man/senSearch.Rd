% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/senSearch.R
\name{senSearch}
\alias{senSearch}
\title{Search Sentinel images}
\usage{
senSearch(username, password, ...)
}
\arguments{
\item{username}{ESA’s `SciHub' username.}

\item{password}{ESA’s `SciHub' password.}

\item{...}{arguments for nested functions:
\itemize{
  \item \code{product} the type of Sentinel product.  Ex. "S2MSI1C",
  "S2MSI2A", "S2MSI2Ap", ...
  \item \code{dates} a vector with the capturing dates being searched. This
  argument is mandatory if \code{startDate} and \code{endDate} are not defined.
  \item  \code{startDate} a \code{Date} class object with the starting date of the 
study period. This argument is mandatory if 
  \code{dates} is not defined.
  \item  \code{endDate} a \code{Date} class object with the ending date of the 
study period. This argument is mandatory if 
  \code{dates} is not defined.
  \item \code{region} a \code{Spatial*}, projected \code{raster*}, or 
  \code{sf} class object defining the area of interest. This argument is
  mandatory if \code{extent} or \code{lonlat} are not defined.
  \item \code{extent} an \code{extent}, \code{Raster*}, or \code{Spatial*}
  object representing the region of interest with longitude/latitude
  coordinates. This argument is mandatory if \code{region} or \code{lonlat}
  are not defined.
  \item \code{lonlat} a vector with the longitude/latitude
  coordinates of the point of interest. This argument is mandatory if 
  \code{region} or \code{extent} are not defined.
  \item \code{platform} the name of the Sentinel mission ("Sentinel-1", 
  "Sentinel-2", ...).
  \item \code{qformat} the format of the response.
  \item \code{verbose} logical argument. If \code{TRUE}, the function prints
  the running steps and warnings.
}}
}
\description{
\code{senSearch} searches Sentinel images through ESA's powered application
programming interface (API), called 
\href{http://scihub.copernicus.eu}{`SciHub'}, that concern a particular
location and date interval. The function returns a \code{data.frame} with
the names of the images and their uniform resource locators (URLs).
}
\details{
\code{senSearch} uses the
\href{http://scihub.copernicus.eu}{ESA's powered API} (`SciHub').The catalogue
of Sentinel-2 products can be found
\href{https://sentinel.esa.int/web/sentinel/missions/sentinel-2/data-products}{here}.
The function explores the images available for a specific location and 
time-span. Dates must be provided as \code{Date} class objects. Credentials
from ESA’s `SciHub' are needed and they can be obtained 
\href{https://scihub.copernicus.eu/dhus/#/self-registration}{here}.
}
\examples{
\dontrun{
# load a spatial polygon object of Navarre
data(ex.navarre)
# perform the search query
sres <- senSearch(startDate = as.Date("2018210", "\%Y\%j"),
                  endDate = as.Date("2018218", "\%Y\%j"),
                  platform = "Sentinel-2",
                  region = ex.navarre,
                  product = "S2MSI1C",
                  username = "username",
                  password = "password")
head(sres)
}
}
