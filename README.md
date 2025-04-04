# referencia-geografica-Colombia
Colombian Geographic Database Creation

The objective of this repository is to create a reference geographic database for Colombia.
Its use is mostly thought for the researchers of the *Instituto de Investigación de Recursos Biológicos Alexander von Humboldt* (Colombian Research Institute on biodiversity).

There is a need for a reference database so all the researchers of the institute can refer to the same maps when they treat spatial data from Colombia.
The first work on this database is to present a geographic layer that goes from the "vereda" level.
In the Colombian administrative structure of the territory, this level is lower than the municipalities (i.e. "municipios" contain usually various veredas).
However, most dense urban areas are not considered in the veredas, which means that, in order to get a map at this level without "holes", we need to concatenate urban areas and veredas.
Since urban areas and veredas are both included in municipalities, and municipalities in departments (departamento), it is then possible to determine all major level of administrative geographic structure from such a concatenated dataset.

There are various potential applications for such a dataset:

1. spatial representation of the territory
1. checking geographic consistency of existing datasets (relations between locality description and coordinates)
1. extracting directly administrative location information based on spatial objects

For the spatial representation, people need to be able to access directly the complete geographic layers, which can be done from a central database.
For checking geographic consistency and the extraction of location information, this can be done through applications using the dataset.

The work done in its repository should be available through connection and to be repeatable in local machine for heavy use of the dataset.

## Directory structure and use of included documents
There are 2 main directories in the repository:

* [database_creation](./database_creation) contains documents and codes which explain how to create the database from internet sources
* [database_use](./database_use) contains documents and codes to be able to use the database for the main geographic operations (that we thought about...)

Mainly, the codes and information are included in document using quarto, which are compiled into documents that are rendered in github (github-flavour-markdown).

From these documents you may extract the code part of the documents, or compile in other formats.
Please check documentation on quarto documents in the Posit (Rstudio) documentation.
