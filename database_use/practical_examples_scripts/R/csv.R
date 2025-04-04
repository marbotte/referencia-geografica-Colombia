# Minimal example to extract geographic locations from coordinates in a csv ----

## Creating the database connection ----

require(RPostgres)
ipServer <- "192.168.205.2"
password <- "thisIsNotTheRealPassword" # change the password here
database <- "dev_geogref"
user <- "gic"

dgr <- dbConnect(Postgres(), host=ipserver, dbname=database, user = user, password=password)

## Load the function (note you need to download the file)
functionFile<-"../../ptsOnColombia_adm.R" # change the file location here
# You may use : functionFile<-file.choose()

source(functionFile)

## Charge the file with the coordinates ----
require(sf)
coordinate_file <- "../../ejemplo_site_point.csv" # change the file path and name here
# coordinate_file <- file.choose() # use this line to interactively select the file
coordSrid <- 4326 # You may want to change the coordinates system here (see https://epsg.io/)
x_coord_col <- "coord_x" # name of the longitude column
y_coord_col <- "coord_y" # name of the latitude column
columnsForUniqueId <- c("proyecto","site") # Put here the column to create a unique id

dataPoints <- read.csv(coordinate_file)
dataPoints <- st_as_sf(dataPoints, coords= c(x_coord_col,y_coord_col),crs=st_crs(coordSrid))
if(length(columnsForUniqueId)>1)
{
  dataPoints$uniqueId<-apply(dataPoints[columnsForUniqueId],1,paste0)
}
if(length(columnsForUniqueId)==1)
{
  dataPoints$uniqueId<-dataPoints[,columnsForUniqueId]
}

## Use the function, get the results ----

(result <- ptsOnColombia_adm(pts=dataPoints,dbConn = dgr,id="uniqueId"))
# if you want to search within a distance:
#(result <- ptsOnColombia_adm(pts=dataPoints,dbConn = dgr,id="uniqueId", DWithin=1000, indexing=T))


## Write the results in a csv ----
fileResults<-"path/to/file/file.csv"
write.csv(result,fileResults)
