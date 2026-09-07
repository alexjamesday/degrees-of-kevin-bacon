clear screen

prompt |  ____                                         __   _  __          _         ____                        
prompt | |  _ \  ___  __ _ _ __ ___  ___  ___    ___  / _| | |/ /_____   _(_)_ __   | __ )  __ _  ___ ___  _ __  
prompt | | | | |/ _ \/ _` | '__/ _ \/ _ \/ __|  / _ \| |_  | ' // _ \ \ / / | '_ \  |  _ \ / _` |/ __/ _ \| '_ \ 
prompt | | |_| |  __/ (_| | | |  __/  __/\__ \ | (_) |  _| | . \  __/\ V /| | | | | | |_) | (_| | (_| (_) | | | |
prompt | |____/ \___|\__, |_|  \___|\___||___/  \___/|_|   |_|\_\___| \_/ |_|_| |_| |____/ \__,_|\___\___/|_| |_|
prompt |             |___/                                                                                       
             
pause

set termout off
set echo off
clear screen

drop table if exists imdb_person cascade constraints purge;
drop table if exists imdb_title cascade constraints purge;
drop table if exists imdb_role_in_title cascade constraints purge;

set termout on

prompt Creating IMDB tables...
prompt 

set echo on

create table imdb_person
(
  id          number not null, 
  name        varchar2(60) not null, 
  birth_year  number,
  death_year  number
)
.
pause
/

create table imdb_title
(
  id          number not null,
  name        varchar2(200) not null,
  runtime_min number,
  start_year  number,
  end_year    number
)
.
pause
/

create table imdb_role_in_title
(
  title_id    number not null,
  person_id   number not null,
  person_role varchar2(50) not null
)
.
pause
/

clear screen
set echo off
prompt Load data into the IMDB tables...
prompt 

set echo on

host sqlldr userid=dbdemo/dbdemo@db23 control=ctl/imdb_title.ctl data=data/imdb_title.csv skip=1 direct=true
host sqlldr userid=dbdemo/dbdemo@db23 control=ctl/imdb_person.ctl data=data/imdb_person.csv skip=1 direct=true
host sqlldr userid=dbdemo/dbdemo@db23 control=ctl/imdb_role_in_title.ctl data=data/imdb_role_in_title.csv skip=1 direct=true

pause

clear screen
set echo off
prompt Apply constraints to the IMDB tables...
prompt 

set echo on

alter table imdb_person add constraint imdb_person_pk primary key (id);

alter table imdb_title add constraint imdb_title_pk primary key (id);

alter table imdb_role_in_title add
(
  constraint imdb_role_in_title_pk primary key (title_id, person_id, person_role),
  constraint imdb_role_in_title_fk1 foreign key (person_id) references imdb_person,
  constraint imdb_role_in_title_fk2 foreign key (title_id) references imdb_title
);

create index imdb_person_ix on imdb_person (name);

create index imdb_role_in_title_ix on imdb_role_in_title (person_id, title_id);

pause

set linesize 120
column from_person format a15
column title_names format a70
column path_length format 9
column to_person format a15

clear screen
set echo off
prompt Create the property graph object that overlays the IMDB tables...
prompt 

set echo on

create or replace property graph IMDB_GRAPH
vertex tables
(
  imdb_person as person
    key (id)
    properties (id as person_id, name, birth_year, death_year),
  imdb_title as title
    key (id)
    properties (id as title_id, name, runtime_min, start_year)
)
edge tables
(
  imdb_role_in_title as title_to_person
    key (title_id, person_id, person_role)
    source key (title_id) references title (id)
    destination key (person_id) references person (id)
    properties all columns,
  imdb_role_in_title as person_to_title key (title_id, person_id, person_role)
    source key (person_id) references person (id)
    destination key (title_id) references title (id)
    properties all columns
)
.
pause
/

var some_actor varchar2(30)
exec :some_actor := 'Julia Roberts'

pause

select *
from graph_table
(
  imdb_graph
  match
    (p1 is person) ( - [e1 is person_to_title where e1.person_id != p2.person_id] -> (t1 is title) - [e2 is title_to_person where e2.person_id != e1.person_id] -> ){1} (p2 is person)
  where p1.name = :some_actor
  and p1.birth_year is not null
  and p2.name = 'Kevin Bacon'
  and p2.birth_year is not null
  columns
  (
    p1.name as from_person,
    listagg(t1.name, ' -> ') as title_names,
    count(t1.title_id) as path_length,
    p2.name as to_person
  )
)
where rownum <= 10
.
pause
/

pause

select *
from graph_table
(
  imdb_graph
  match
    (p1 is person) ( - [e1 is person_to_title where e1.person_id != p2.person_id] -> (t1 is title) - [e2 is title_to_person where e2.person_id != e1.person_id] -> ){2} (p2 is person)
  where p1.name = :some_actor
  and p1.birth_year is not null
  and p2.name = 'Kevin Bacon'
  and p2.birth_year is not null
  columns
  (
    p1.name as from_person,
    listagg(t1.name, ' -> ') as title_names,
    count(t1.title_id) as path_length,
    p2.name as to_person
  )
)
where rownum <= 10
.
pause
/

pause

select *
from graph_table
(
  imdb_graph
  match
    (p1 is person) ( - [e1 is person_to_title where e1.person_id != p2.person_id] -> (t1 is title) - [e2 is title_to_person where e2.person_id != e1.person_id] -> ){3} (p2 is person)
  where p1.name = :some_actor
  and p1.birth_year is not null
  and p2.name = 'Kevin Bacon'
  and p2.birth_year is not null
  columns
  (
    p1.name as from_person,
    listagg(t1.name, ' -> ') as title_names,
    count(t1.title_id) as path_length,
    p2.name as to_person
  )
)
where rownum <= 10
.
pause
/

pause

clear screen
set echo off
prompt Let us pick a younger actor than Julia Roberts...
prompt

var some_actor varchar2(30)
exec :some_actor := 'Ezra Miller'

pause

select *
from graph_table
(
  imdb_graph
  match
    (p1 is person) ( - [e1 is person_to_title where e1.person_id != p2.person_id] -> (t1 is title) - [e2 is title_to_person where e2.person_id != e1.person_id] -> ){1, 3} (p2 is person)
  where p1.name = :some_actor
  and p1.birth_year is not null
  and p2.name = 'Kevin Bacon'
  and p2.birth_year is not null
  columns
  (
    p1.name as from_person,
    listagg(t1.name, ' -> ') as title_names,
    count(t1.title_id) as path_length,
    p2.name as to_person
  )
)
where rownum <= 10
.
pause
/

pause

REM end