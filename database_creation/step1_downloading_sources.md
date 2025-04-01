# Colombian geographic reference database: downloading sources
Marius Bottin

The idea here is to download automatically the sources so people can
repeat the code for creating the reference database without needing to
make some subjective clicking.

# Sources

We will use 3 main sources for creating the database:

1.  [**Veredas de
    Colombia**](https://serviciosgeovisor.igac.gov.co:8080/Geovisor/descargas?cmd=download&token=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxNzYxODIiLCJleHAiOjE3NDI2MTA3OTgsImp0aSI6InNlcnZpY2lvXzAtNjkwIn0.q0kz4SRuQy-iZTI9Fnn6-Xn6RCphnq36Bv7Zg_V8PCI7MME6GjlIowq3FcWAdu-DmuFGgw4Pi8UxqdO5_N_sYw)
    (IGAC 2020)
2.  [**Centros poblados y cabeceras municipales de
    Colombia**](https://geoportal.dane.gov.co/descargas/mgn_2020/MGN2020_URB_AREA_CENSAL.rar)
    (DANE 2020)
3.  [**Resguardo Indigena
    Formalizado**](https://hub.arcgis.com/api/v3/datasets/8944116ccfd34a7189c4bc44b8e19186_0/downloads/data?format=shp&spatialRefId=4686&where=1%3D1)
    (ANT 2025)

Of course, in the future, it would make sense to add some other
information in this reference database (roads, rivers, protected areas,
predios etc). However, for now, this lot may help us undertand how to
create a reference database.

# Download

The idea here is to create a code that creates the folder, download the
compressed files and extract the final files. Of course we should not
download them again when they are already in our computers (let’s be
“polite” with the institutions sharing the data). So the process will be
as follows:

1.  creating a table containing the name of the resource, the download
    link, the name of one of the file it should contain so we have a way
    to test presence in the
2.  if the external data folder does not exist: creating it
3.  check whether the file is in the data folder, if already there, stop
4.  download the compressed file in a temporary folder
5.  extract the data files in the external data folder

``` r
# Creating the information table
(toDownload<-data.frame(
  name=c("veredas", "centPobl", "resguardo"),
  title=c("Veredas de Colombia", "Centros poblados y cabeceras municipales de Colombia", "Resguardo Indigena Formalizado"),
  download=c("https://serviciosgeovisor.igac.gov.co:8080/Geovisor/descargas?cmd=download&token=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxNzYxODIiLCJleHAiOjE3NDI2MTA3OTgsImp0aSI6InNlcnZpY2lvXzAtNjkwIn0.q0kz4SRuQy-iZTI9Fnn6-Xn6RCphnq36Bv7Zg_V8PCI7MME6GjlIowq3FcWAdu-DmuFGgw4Pi8UxqdO5_N_sYw", "https://geoportal.dane.gov.co/descargas/mgn_2020/MGN2020_URB_AREA_CENSAL.rar", "https://hub.arcgis.com/api/v3/datasets/8944116ccfd34a7189c4bc44b8e19186_0/downloads/data?format=shp&spatialRefId=4686&where=1%3D1"),
  type=c("zip", "rar", "zip"),
  testFile=c("CRVeredas_2020.shp", "MGN_URB_AREA_CENSAL.shp", "Resguardo_Indigena_Formalizado.shp")
))
```

| name | title | download | type | testFile |
|:---|:---|:---|:---|:---|
| veredas | Veredas de Colombia | https://serviciosgeovisor.igac.gov.co:8080/Geovisor/descargas?cmd=download&token=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxNzYxODIiLCJleHAiOjE3NDI2MTA3OTgsImp0aSI6InNlcnZpY2lvXzAtNjkwIn0.q0kz4SRuQy-iZTI9Fnn6-Xn6RCphnq36Bv7Zg_V8PCI7MME6GjlIowq3FcWAdu-DmuFGgw4Pi8UxqdO5_N_sYw | zip | CRVeredas_2020.shp |
| centPobl | Centros poblados y cabeceras municipales de Colombia | https://geoportal.dane.gov.co/descargas/mgn_2020/MGN2020_URB_AREA_CENSAL.rar | rar | MGN_URB_AREA_CENSAL.shp |
| resguardo | Resguardo Indigena Formalizado | https://hub.arcgis.com/api/v3/datasets/8944116ccfd34a7189c4bc44b8e19186_0/downloads/data?format=shp&spatialRefId=4686&where=1%3D1 | zip | Resguardo_Indigena_Formalizado.shp |

On the process we will need a function that will allow to unpack the
downloaded compressed files depending on their type. If you are on
Windows, first you have to know that it is a very bad idea to do
anything on Windows, second, please know that I will not test my code
for your system! On consequence, if you are working on Windows, please
be extra-careful here, we would not like to make your system worse than
it already is… I am willing to change my code for more compatibility for
your system, though.

It works on my computer (6.6.74-gentoo-x86_64)

``` r
existUnrar<-function()
{
  return(Sys.which('unrar')!="")
}
unpackArchive<-function(compressedFile,destDir,type=c("zip","rar"))
{
  type<-match.arg(type)
  if(type=="rar")
  {
    if(!existUnrar())
    {
      stop("The compressed archive is of rar types.
          It does not have a R package (that I know of...) and
          unrar can't be accessed on your system.
          Please install it (you may check on the installr::install.7zip function,
          or, even better, use your package manager to install directly unrar).
          The objective here is to have a working unrar command in you command path.")
    }
    return(system(paste0("unrar e ",compressedFile," ",destDir)))
  }
  if(type=="zip")
  {
    return(unzip(compressedFile,exdir=destDir))
  }
}
```

``` r
# Creating the external data folder
extDatFol<-"../sourceMaps"
if(!dir.exists(extDatFol)){
  dir.create(extDatFol)
}
# Check on the existence of the 3 files
files<-dir(extDatFol,recursive=T)
bs_files<-basename(files)
testExist<-toDownload$testFile%in%bs_files
names(testExist)<-toDownload$name
print(testExist)
```

      veredas  centPobl resguardo 
         TRUE      TRUE      TRUE 

``` r
# Download compressed files
if(sum(!testExist))
{
  (downl_temp_dir<-tempdir())
  downl_files<-paste0(downl_temp_dir,"/",toDownload$name[!testExist],".",toDownload$type[!testExist])
  destDir<-paste0(extDatFol,"/",toDownload$name[!testExist],"/")
  for(i in 1:length(downl_files))
  {
# download the files
    download.file(url=toDownload$download[!testExist][i],destfile = downl_files[i])
# extraxt the data files from the downloaded compressed archive
    unpackArchive(downl_files[i],destDir = destDir[i],type=toDownload$type[!testExist][i])
  }
  
}
write.csv(toDownload,paste0(extDatFol,"/sourcesDownloaded.csv"))
```

Files should be downloaded and extracted in their respective subfolder
in \<./sourceMaps/\>

# References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-ANT2025" class="csl-entry">

ANT. 2025. “Resguardo Indigena Formalizado.”
<https://data-agenciadetierras.opendata.arcgis.com/datasets/agenciadetierras::resguardo-indigena-formalizado/about>.

</div>

<div id="ref-DANE2020" class="csl-entry">

DANE. 2020. “Centros Poblados y Cabeceras Municipales de Colombia.”
<https://www.colombiaenmapas.gov.co/?e=-79.41660754882827,1.848386125384518,-73.09946887695497,6.192693508549228,4686&b=igac&u=0&t=29&servicio=591>.

</div>

<div id="ref-IGAC2020" class="csl-entry">

IGAC. 2020. “Veredas de Colombia.”
<https://mapas.igac.gov.co/server/rest/services/limites/veredascolombia/MapServer>.

</div>

</div>
