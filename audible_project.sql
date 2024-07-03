select * from audible_uncleaned;

create table audible_uncleaned_staging
like audible_uncleaned;

insert audible_uncleaned_staging
select * from audible_uncleaned;

select * from audible_uncleaned_staging;

select *, row_number() over(partition by name) as row_num
from audible_uncleaned_staging;

with duplicate_cte as (
select *, row_number() over(partition by name) as row_num
from audible_uncleaned_staging) 

select * from duplicate_cte
where row_num > 1;

CREATE TABLE `audible_uncleaned_staging2` (
  `name` text,
  `author` text,
  `narrator` text,
  `time` text,
  `releasedate` text,
  `language` text,
  `stars` text,
  `price` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into audible_uncleaned_staging2
select *, row_number() over(partition by name) as row_num
from audible_uncleaned_staging;

select * from audible_uncleaned_staging2
where row_num >1;

delete
from audible_uncleaned_staging2
where row_num >1;-- Duplicates deleted.

select * from audible_uncleaned_staging2
order by name;


select author, trim(leading 'Writtenby:' from author) from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set author = trim(leading 'Writtenby:' from author);

select narrator, trim(leading 'Narratedby:' from narrator) from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set narrator = trim(leading 'Narratedby:' from narrator);

-- Query to split names on capital letters and add whitespace
-- NEED TO RESEARCH FOR THE NAMES.

SELECT *
FROM audible_uncleaned_staging2;

SELECT 
  author,
  SUBSTRING(author, 1, CHAR_LENGTH(author) - CHAR_LENGTH(SUBSTRING_INDEX(author, '[A-Z]', -1))) AS first_name,
  SUBSTRING_INDEX(SUBSTRING(author, CHAR_LENGTH(author) - CHAR_LENGTH(SUBSTRING_INDEX(author, '[A-Z]', -1)) + 1), '[A-Z]', 1) AS last_name
FROM audible_uncleaned_staging2;

SELECT 
  author,
  TRIM(SUBSTRING_INDEX(REGEXP_REPLACE(author, '([A-Z])', ' $1'), ' ', 1)) AS first_name,
  TRIM(SUBSTRING_INDEX(REGEXP_REPLACE(author, '([A-Z])', ' $1'), ' ', -1)) AS last_name
FROM 
  audible_uncleaned_staging2;

SELECT author, (REGEXP_REPLACE(author, '([A-Z])', ' $1', 2, 0, 'c')) as author1 from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set author = (REGEXP_REPLACE(author, '([A-Z])', ' $1', 2, 0, 'c'));

SELECT narrator, (REGEXP_REPLACE(narrator, '([A-Z])', ' $1', 2, 0, 'c')) as author1 from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set narrator= (REGEXP_REPLACE(narrator, '([A-Z])', ' $1', 2, 0, 'c'));

select stars, trim(substring_index(stars, 'stars', 1)),
trim(substring_index(stars, 'stars', -1)) as ratings
from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set stars = trim(substring_index(stars, 'stars', 1));

alter table audible_uncleaned_staging2
add column rating varchar(20);

update audible_uncleaned_staging2
set rating = trim(substring_index(stars, 'stars', -1));

select * from audible_uncleaned_staging2;

select releasedate, str_to_date(releasedate, '%d-%m-%y') from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set releasedate= str_to_date(releasedate, '%d-%m-%y');

alter table audible_uncleaned_staging2
modify column `releasedate` DATE;

select `time` , replace(`time`, ' and ' , ' ') from audible_uncleaned_staging2;

update audible_uncleaned_staging2
set `time` = replace(`time`, ' and ' , ' ');

select * from audible_uncleaned_staging2;

alter table audible_uncleaned_staging2
drop column row_num;

select * from audible_uncleaned_staging2;







