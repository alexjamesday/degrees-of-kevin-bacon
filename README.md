# degrees-of-kevin-bacon
An Oracle 26ai demo which highlights the power of SQL Property Graph, using Kevin Bacon as the cornerstone.

Instructions for use:
* Ensure the database is 26ai and has a user called DBDEMO (password the same)
* Ensure the user DBDEMO has sufficient privileges to create both TABLEs and PROPERTY GRAPHs
* Ensure you have an Oracle Instant Client which includes the SQL*Loader tool (this is used to load the IMDB data set)
* Ensure you run the script "degrees_of_bacon.sql" whilst its directory is your current working directory (there are relative references to sub-directories "data" and "ctl" as part of the SQL*Loader calls)
