/*
Create distinct list of authors from to be used in creation of user mapping
*/

select distinct author, REPLACE(REPLACE(author, ' ', ''), '.', '') AS cleaned_author
from Baldante_highrise..emails e

union all

select distinct author, REPLACE(REPLACE(author, ' ', ''), '.', '') AS cleaned_author
from Baldante_highrise..notes n

union all

select distinct author, REPLACE(REPLACE(author, ' ', ''), '.', '') AS cleaned_author
from Baldante_highrise..tasks t