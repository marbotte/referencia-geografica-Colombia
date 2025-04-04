# Connecting the database to Qgis: example in the Humboldt institute
Marius Bottin

In this document we will show how to connect Qgis to the database.

Open Qgis and look for the PostgreSQL option in the browser, right
click, new connection:

![Creating a Postgres connection](Fig/connectingQgis_1.png)

Next enter the following configuration (this should work in the Humboldt
institute network and through the institute vpn).

![Connection configuration](Fig/connectingQgis2.png)

Now you may browse the database:

![Browsing the database](Fig/connectingQgis3.png)

Note, this is a development database, there are a lot of objects which
are there because I worked dirty… The most interesting object is the
`vereda_cpob` one!
