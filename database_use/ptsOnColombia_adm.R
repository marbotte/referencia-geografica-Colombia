# ptsOnColombia_adm checks on which administrative geographic elements are points given in a sf spatial object
# arguments:
# pts: sf object with all the points that need to be checked
# dbConn: connection to the reference database (note that this database needs to have particular table, with particular fields), it needs to use the RPostgres::Postgres() driver 
# id: id for returning results, it may be a column name of the sf object (needs to be unique) if it is NA, an id column is created with 1:nrow(pts)
# DWithin: if this is not NA, it should contain a distance in meter, the function will then return a supplentary column with the dane cd and names of other elements at this distance
# indexing: should the temporary table with the points in the database be spatially indexed (may speed up the process for large datasets)

ptsOnColombia_adm <- function(
    pts,
    dbConn,
    id=NA,
    DWithin=NA,
    indexing=F
    )
{
  #daneOrName <- match.arg(daneOrName,c("both","names","dane"))
  createId<-is.na(id)
  if(createId){
    pts<-st_sf(id=1:nrow(pts),st_geometry(pts))
    id<-"id"
  }else{
    if(!id %in% colnames(pts)){stop("Given id column is not in the data")}
    if(any(duplicated(pts[,id,drop=T]))){stop("Given ids are not unique")}
    pts<-pts[,id,drop=F]
  }
  pts<-st_set_geometry(pts,"geom")
  dbSrid<-st_crs(dbGetQuery(dbConn,"SELECT Find_SRID('public','vereda_cpob','the_geom') as srid")$srid)
  ptsSrid<-st_crs(pts)
  sameSrid<-(dbSrid==ptsSrid)
  dbBegin(dbConn)
  st_geometry(pts)<-'geom'
  geom<-'geom'
  st_write(dsn=dbConn,obj=pts,layer='pts',temporary=T)
  if(!sameSrid)
  {
    dbExecute(dbConn,"SELECT AddGeometryColumn('pts','tr_geom',(SELECT Find_SRID('public','vereda_cpob','the_geom')),'POINT',2)")
    dbExecute(dbConn,"UPDATE pts SET tr_geom=ST_Transform(geom,(SELECT Find_SRID('public','vereda_cpob','the_geom')))")
    geom<-"tr_geom"
  }
  if(indexing)
  {
    dbExecute(dbConn,paste0("CREATE INDEX pts_spat_idx ON ",dbQuoteIdentifier(dbConn,Id(table="pts"))," USING GIST(",dbQuoteIdentifier(dbConn,geom),")"))
  }
  (q_select<-paste0("SELECT ",
                    paste(dbQuoteIdentifier(dbConn,Id(table="pts", column=id)),
                          "CASE 
                            WHEN vereda_cpob.cd_ver IS NULL AND vereda_cpob.cd_cpob IS NOT NULL THEN 'centro poblado'
                            WHEN vereda_cpob.cd_ver IS NOT NULL AND vereda_cpob.cd_cpob IS NULL THEN 'vereda'
                            ELSE 'not found'
                          END AS \"type_found\"",
                          dbQuoteIdentifier(dbConn,Id(table="vereda_cpob", column="cd_ver")),
                          dbQuoteIdentifier(dbConn,Id(table="vereda_cpob", column="cd_cpob")),
                          paste(dbQuoteIdentifier(dbConn,Id(table="vereda_cpob", column="name")),dbQuoteIdentifier(dbConn,"vereda_cpob"),sep=" AS "),
                          dbQuoteIdentifier(dbConn,Id(table="municipio", column="cd_mpio")),
                          dbQuoteIdentifier(dbConn,Id(table="municipio", column="municipio")),
                          dbQuoteIdentifier(dbConn,Id(table="departamento", column="cd_dpto")),
                          dbQuoteIdentifier(dbConn,Id(table="departamento", column="departamento")),
                          dbQuoteIdentifier(dbConn,Id(table="vereda_cpob", column="fuente")),
                   sep=", ")
  ))
  if(!is.na(DWithin)){q_select<-paste0(q_select,", ST_Distance(",dbQuoteIdentifier(dbConn,Id(table="pts",column=geom)), ",",dbQuoteIdentifier(dbConn,Id(table="vereda_cpob",column="the_geom")),",true) distance_m")}
  (q_from <- paste0("FROM ",dbQuoteIdentifier(dbConn,"pts")))
  q_join1<-paste0("LEFT JOIN ",
                dbQuoteIdentifier(dbConn,Id(table="vereda_cpob")),
                " ON ",
                ifelse(is.na(DWithin),"ST_Intersects(","ST_DWithin("),
                dbQuoteIdentifier(dbConn,Id(table="pts",column=geom)),
                ", ",
                dbQuoteIdentifier(dbConn,Id(table="vereda_cpob",column="the_geom")),
                ifelse(is.na(DWithin),")",paste(",",dbQuoteLiteral(dbConn,DWithin),", true)"))
  )
  q_join_other<-"LEFT JOIN municipio USING (cd_mpio,cd_dpto)
  LEFT JOIN departamento USING (cd_dpto)"
  query<-paste(q_select,q_from,q_join1,q_join_other,sep="\n") 
  res <- dbGetQuery(dbConn,query)
  m<-match(res[,id],pts[,id,drop=T])
  res<-res[order(m),]
  dbRollback(dbConn)
  
  return(res)
}