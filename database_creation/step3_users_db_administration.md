# Colombian geographic reference database: development database creation
Marius Bottin

Here we will describe some operations for the database administration.
In particular, we will create users for the database use. In our case
the connection will be possible from the Humboldt Institute network. The
PostgreSQL cluster has been set up for accepting these connections, and
we will not give details about the setup process.

``` r
require(RPostgres)
```

    Loading required package: RPostgres

``` r
dgr<-dbConnect(Postgres(), dbname="dev_geogref")
```

## Role: geogref_user

First we check if it exists:

``` sql
SELECT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'geogref_user')
```

Then, if it does not exist we create it (note: if the user exist, the
sql chunk won’t be evaluated).

``` r
if(!gru$exists)
  dbExecute(dgr,"
CREATE ROLE geogref_user WITH
  NOSUPERUSER
  NOLOGIN
  NOCREATEDB
  NOCREATEROLE;
  ")
```

## Grant minimum priviledge

``` sql
GRANT CONNECT ON DATABASE dev_geogref TO geogref_user;
```

``` sql
GRANT USAGE ON SCHEMA public TO geogref_user;
```

## Create the real users

In order to avoid divulgating the password of the users, I create a file
which is not shared in github and contains the passwords.

------------------------------------------------------------------------

The password file is a csv file (separator: `,`), the user in first
column and password in the second one, no header.

------------------------------------------------------------------------

``` r
passwordFile<-"../password"
pw<-read.csv(passwordFile,h=F,row.names=1)
pw_gic <- pw["gic",1]
```

Now we check whether the gic user exists in the cluster, if it does not
exist we create it. Then we grant it geogref_user so all the priviledges
of this role are transfered to gic.

``` r
gic_exists<-dbGetQuery(dgr,"SELECT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'gic')")$exists
if(!gic_exists)
{
  dbSendQuery(dgr,statement=paste0("CREATE USER gic WITH NOCREATEDB NOCREATEROLE PASSWORD ",dbQuoteString(dgr,pw_gic)))
}
dbSendQuery(dgr,"GRANT geogref_user TO gic")
```

    <PqResult>
      SQL  GRANT geogref_user TO gic
      ROWS Fetched: 0 [complete]
           Changed: 0

# Turning off the light and leaving

``` r
dbDisconnect(dgr)
```

    Warning: There is a result object still in use.
    The connection will be automatically released when it is closed
