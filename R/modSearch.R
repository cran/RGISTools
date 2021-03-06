#' Search MODIS images
#'
#' \code{modSearch} searches MODIS images in the 
#' \href{https://lpdaacsvc.cr.usgs.gov/services/inventory}{NASA Common Metadata Repository}
#' (CMR) concerning a particular location and date interval. The function returns a 
#' \code{character} vector with the names of the images and their uniform resource
#' locators (URLs)
#'
#' \code{modSearch} uses the
#' \href{https://lpdaacsvc.cr.usgs.gov/services/inventory}{NASA Common Metadata
#' Repository} (CMR) powered API. The catalogue of MODIS products can be found
#' \href{https://modis.gsfc.nasa.gov/data/dataprod/}{here}.
#' The catalogue shows the product short names and provides detailed information
#' about the product. By the time `RGISTools' is released, NASA carries out the
#' maintenance of its website on Wednesdays, which may cause an error when
#' connecting to their server. You can get your `EarthData' credentials
#' \href{https://urs.earthdata.nasa.gov/users/new}{here}.
#' 
#' The function can be used to retrieve the web address of the preview 
#' (\code{resType = "browseurl"}) or the actual image (\code{resType = "url"}).
#' By default, the URL points towards the actual image.
#'
#' @param product the short name of the MODIS product.
#' @param collection MODIS collection. By default, 6.
#' @param verbose logical argument. If \code{TRUE}, the function prints the 
#' running steps and warnings.
# @param pathrow A list of vectors defining the path and row number for the region of interest according
# to the Sinusoidal Tile Grid (\url{https://modis-land.gsfc.nasa.gov/MODLAND_grid.html})
# This argument is mandatory if extent is not defined.
#' @param ... arguments for nested functions:
#' \itemize{
#'   \item \code{dates} a vector with the capturing dates being searched. This
#'   argument is mandatory if \code{startDate} and \code{endDate} are not defined.
#'   \item  \code{startDate} a \code{Date} class object with the starting date 
#'   of the study period. This argument is mandatory if \code{dates} is not defined.
#'   \item  \code{endDate} a \code{Date} class object with the ending date of the 
#' study period. This argument is mandatory if 
#'   \code{dates} is not defined.
#'   \item \code{region} a \code{Spatial*}, projected \code{raster*}, or \code{sf}
#'   class object defining the area of interest. This argument is mandatory if
#'   \code{extent} or \code{lonlat} are not defined.
#'   \item \code{lonlat} a vector with the longitude/latitude
#'   coordinates of the point of interest. This argument is mandatory if 
#'   \code{region} or \code{extent} are not defined.
#'   \item \code{extent}  an \code{extent}, \code{Raster*}, or 
#'   \code{Spatial*} object representing the region of interest with 
#'   longitude/latitude coordinates. This argument is mandatory if 
#'   \code{region} or \code{lonlat} are not defined.
#' }
#' @return a \code{vector} with the url for image downloading.
#' @examples
#' \dontrun{
#' # load a spatial polygon object of Navarre with longitude/latitude coordinates
#' data(ex.navarre)
#' # searching MODIS MYD13A2 images between 2011 and 2013 by longitude/latitude
#' # using a polygon class variable
#' sres <- modSearch(product = "MYD13A2",
#'                   startDate = as.Date("01-01-2011", "%d-%m-%Y"),
#'                   endDate = as.Date("31-12-2013", "%d-%m-%Y"),
#'                   collection = 6,
#'                   extent = ex.navarre)
#' # region of interest: defined based on longitude/latitude extent
#' # searching MODIS MYD13A2 images in 2010 by longitude/latitude
#' # using a extent class variable defined by the user
#' aoi = extent(c(-2.49, -0.72, 41.91, 43.31))
#' sres <- modSearch(product = "MYD13A2",
#'                   startDate = as.Date("01-01-2010", "%d-%m-%Y"),
#'                   endDate = as.Date("31-12-2010", "%d-%m-%Y"),
#'                   collection = 6,
#'                   extent = aoi)
#' head(sres)
#' }
modSearch<-function(product,collection=6,verbose=FALSE,...){
  arg=list(...)
  if("resType"%in%names(arg)){warning("resType argument it is obsolete.")}
  if((!"dates"%in%names(arg))&
     ((!"startDate"%in%names(arg)|(!"endDate"%in%names(arg))))
  )stop("startDate and endDate, or dates argument need to be defined!")
  
  if("dates"%in%names(arg)){
    stopifnot(class(arg$dates)=="Date")
    startDate<-min(arg$dates)
    endDate<-max(arg$dates)
  }else{
    startDate<-arg$startDate
    endDate<-arg$endDate
  }
  
  stopifnot(class(startDate)=="Date")
  stopifnot(class(endDate)=="Date")
  
  modisres <- list()
  modtype<-c("url","browseurl")
  for(resType in modtype){
    if(any(names(arg)%in%c("pathrow"))){
      stopifnot(class(arg$pathrow)=="list")
      stop("pathrow search not supported for Modis Search")
    }else if("lonlat"%in%names(arg)){
      stopifnot(class(arg$lonlat)=="numeric")
      stopifnot(length(arg$lonlat)==2)
      loc<-paste0(getRGISToolsOpt("MODINVENTORY.url"),
                  "?product=",product,
                  "&version=",collection,
                  "&latitude=",arg$lonlat[2],
                  "&longitude=",arg$lonlat[1],
                  "&return=",resType,
                  "&date=",format(startDate,"%Y-%m-%d"),
                  ",",format(endDate,"%Y-%m-%d"))
    }else if("extent"%in%names(arg)){
      stopifnot(class(extent(arg$extent))=="Extent")
      loc<-paste0(getRGISToolsOpt("MODINVENTORY.url"),
                  "?product=",product,
                  "&version=",collection,
                  "&bbox=",paste0(c(st_bbox(arg$extent)),collapse = ","),
                  "&return=",resType,
                  "&date=",format(startDate,"%Y-%m-%d"),
                  ",",format(endDate,"%Y-%m-%d"))
    }else if("region"%in%names(arg)){
      arg$region<-transform_multiple_proj(arg$region, proj4=st_crs(4326))
      loc<-paste0(getRGISToolsOpt("MODINVENTORY.url"),
                  "?product=",product,
                  "&version=",collection,
                  "&bbox=",paste0(st_bbox(arg$region),collapse = ","),
                  "&return=",resType,
                  "&date=",format(startDate,"%Y-%m-%d"),
                  ",",format(endDate,"%Y-%m-%d"))
    }else{
      stop('Search method not defined.')
    }
    
    if(verbose){
      message(paste0("Search query: ",loc))
    }
    c.handle = new_handle()
    req <- curl(loc, handle = c.handle)
    html<-readLines(req)
    html<-paste(html,collapse = "\n ")
    
    if(grepl("Internal Server Error", html)){
      stop(paste0("Error: ",getRGISToolsOpt("MODINVENTORY.url")," web out of service"))
    }
    xmlres <- xmlRoot(xmlNativeTreeParse(html))
    modisres[[resType]] <- xmlSApply(xmlres,
                                    function(x) xmlSApply(x,xmlValue))
    close(req)
  }
  
  
  searchres<-list(hdf=modisres[[1]],
                  jpg=modisres[[2]])
  
  
  #filter dates
  if("dates"%in%names(arg)){
    hdfdates<-modGetDates(modisres$hdf)
    modisres$hdf<-modisres$hdf[hdfdates%in%arg$dates]
    jpgdates<-modGetDates(modisres$jpg)
    modisres$jpg<-modisres$jpg[jpgdates%in%arg$dates]
  }
  class(searchres)<-"modres"
  return(searchres)
}

