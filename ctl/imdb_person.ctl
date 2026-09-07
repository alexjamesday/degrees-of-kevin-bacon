LOAD DATA
CHARACTERSET AL32UTF8
APPEND
INTO TABLE imdb_person
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  ID          integer external,
  NAME        char(60),
  BIRTH_YEAR  integer external,
  DEATH_YEAR  integer external
)