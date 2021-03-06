#' Compute a remote sensing index from a time series of Landsat-8 images 
#'
#' \code{ls8FolderToVar} computes a remote sensing index from the spectral bands
#' of a time series of Landsat-8 images. The images are specified by the path to
#' the folder that stores the imagery (resulting from the \code{\link{lsMosaic}} 
#' function). The function returns a \code{RasterStack} with a time series of 
#' images of the remote sensing index.
#'
#' The function requires the definition of the \code{src} and \code{fun} 
#' arguments. The \code{src} is usually the path resulting from 
#' \code{\link{lsMosaic}}.The \code{fun} argument can be any function from this
#' package beginning with “var” (\code{\link{varNDVI}}, \code{\link{varEVI}},
#' etc.). Custom functions can also be implemented. If \code{fun = varRGB}, 
#' then the argument \code{getStack} must be equal to \code{FALSE} and the 
#' red-green-blue (RGB) images must be imported afterwards. Caution! It is mandatory to 
#' use level-2 products to get accurate derived variables.
#' 
#' @param src path to the folder with the Landsat-8 multispectral image.
#' @param fun a \code{function} that computes the remote sensing index.
#' @param AppRoot the directory of the outcoming time series.
#' @param getStack logical argument. If \code{TRUE}, returns the time series of
#' images as a \code{RasterStack}, otherwise the images are saved in the Hard
#' Drive Device (HDD).
#' @param overwrite logical argument. If \code{TRUE}, overwrites the existing
#' images with the same name.
#' @param verbose logical argument. If \code{TRUE}, the function prints the
#' running steps and warnings.
#' @param ... arguments for nested functions.
#'  \itemize{
#'   \item \code{dates} a vector with the capturing dates being considered
#'   for mosaicking. If not supplied, all dates are mosaicked.
#' }
#' @return this function does not return anything, unless \code{getStack = TRUE}
#' which then returns a \code{RasterStack} with the time series of with the
#' index.
#'
#' @examples
#' \dontrun{
#' # load a spatial polygon object of Navarre
#' data(ex.navarre)
#' # main output directory
#' wdir <- file.path(tempdir(),"Path_for_downloading_folder")
#' print(wdir)
#' # download Landsat-8 images
#' lsDownSearch(satellite = "ls8",
#'              username = "username",
#'              password = "password",
#'              startDate = as.Date("01-01-2018","%d-%m-%Y"),
#'              endDate = as.Date("18-01-2018","%d-%m-%Y"),
#'              pathrow = list(c(200, 31), c(200, 30)),
#'              untar = TRUE,
#'              AppRoot = wdir)
#' # folder with the Landsat-8 untared images
#' src.ls8 <-file.path(wdir,"Landsat8")
#' src.ls8.untar <- file.path(src.ls8, "untar")
#' # mosaic the Landsat-8 images
#' lsMosaic(src = src.ls8.untar,
#'          AppRoot = src.ls8,
#'          out.name = "Navarre",
#'          extent = ex.navarre,
#'          gutils = TRUE)
#' # path to the folder with mosaicked images
#' src.ls8.navarre <- file.path(src.ls8, "Navarre")
#' # generate NDVI images of Navarre
#' src.ls8.var <- file.path(src.ls8, "Navarre_Variables")
#' dir.create(src.ls8.var)
#' ls8FolderToVar(src.ls8.navarre,
#'                fun = varNDVI,
#'                AppRoot = src.ls8.var,
#'                overwrite = TRUE)
#'                
#' files.ls8.ndvi <- list.files(file.path(src.ls8.var,"NDVI"),
#'                              pattern = "\\.tif$",
#'                              full.names = TRUE,
#'                              recursive = TRUE)
#' 
#' img.ls8.ndvi <- raster(files.ls8.ndvi[1])
#' spplot(img.ls8.ndvi)
#' }
ls8FolderToVar<-function(src,fun,AppRoot,getStack=FALSE,overwrite=FALSE,verbose=FALSE,...){
  function.arg<-list(...)
  vartype<-gsub("var","",as.character(match.call()[c("fun")]))
  src<-pathWinLx(src)
  AppRoot<-pathWinLx(AppRoot)
  
  if(!getStack){
    AppRoot<-file.path(AppRoot,vartype)
    dir.create(AppRoot,showWarnings = FALSE,recursive=TRUE)
    message(vartype)
  }
  ls.list<-list.files(src,full.names = TRUE)
  
  dates<-genGetDates(ls.list)
  if("dates"%in%names(function.arg)){
    ls.list<-ls.list[dates%in%function.arg$dates]
  }
  
  rstack<-NULL
  result<-NULL
  if(length(ls.list)==0)stop(paste0("No images found in ",src," path."))
  for(imgfd in ls.list){
    message(paste0("Calculating ",vartype," at date ",genGetDates(imgfd),"."))
    ls8bands<-getRGISToolsOpt("LS8BANDS")
    ls.img<-list.files(imgfd,full.names = TRUE,pattern = "\\.tif$")
    if(length(ls.img)==0){
      message(paste0("Images not found in ",imgfd))
      next
    }
    out.file.name<-paste0(AppRoot,"/",vartype,"_",format(genGetDates(imgfd),"%Y%j"),".tif")
    if(overwrite|(!file.exists(out.file.name))){
      funString<-"result<-fun("
      #band load and asignation
      funargs<-formalArgs(fun)
      for(arg in funargs){
        band<-ls8bands[names(ls8bands)%in%arg]
        if(length(band)==0)
          next
        eval(parse( text=paste0(arg,"<-read_stars('",ls.img[grepl(band,ls.img)],"')") ))
        funString<-paste0(funString,arg,"=",arg,",")
      }
      # arguments asignation
      arguments<-as.list(match.call())
      arguments<-arguments[names(arguments)%in%funargs&
                             (!names(arguments)%in%names(ls8bands))]
      for(arg in names(arguments)){
        funString<-paste0(funString,arg,"=function.arg$",arg,",")
      }
      # complete the function
      funString<-paste0(substr(funString,1,nchar(funString)-1),")")
      if(verbose){message(paste0("Function for evaluation: \n",funString))}
      eval(parse(text=funString))
      if(getStack){
        if(is.null(rstack)){
          names(result)<-paste0(vartype,"_",format(genGetDates(imgfd),"%Y%j"))
          rstack<-result
        }else{
          result<-extend(result,rstack)
          names(result)<-paste0(vartype,"_",format(genGetDates(imgfd),"%Y%j"))
          rstack<-extend(rstack,result)
          rstack<-addLayer(rstack,result)
        }
      }else{
        write_stars(result,out.file.name)
      }
    }else{
      message(paste0("File exists!\nFile: ",out.file.name))
    }
  }
  if(getStack){
    return(rstack)
  }else{
    message(paste0(vartype," images saved in HDD"))
    message(paste0("File dir: ",AppRoot))
  }
}
