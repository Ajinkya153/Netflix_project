SELECT * FROM public.netflix
LIMIT 100

-- data exploration 

select * from netflix;

select distinct type
from netflix;

-- 1. Count the number of Movies vs TV Shows

select type, count(*)
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type, rating from
(
select type, rating, count(*),
rank()over(partition by type order by count(*) desc) as ranking
from netflix
group by 1,2
) 
as Ranked
where ranking=1 ;

--3. List all movies released in a specific year (e.g., 2020)
select * from netflix
where type= 'Movie'
and
release_year = 2020;

select title as Movies_2020 from netflix 
where type= 'Movie'
and
release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix


select 

trim(unnest(string_to_array(country,','))) as New_Country,
count(show_id) as total_count

from netflix
group by 1
order by 2 desc
limit 5;

--5. Identify the longest movie and longest TV show

select * from Netflix
where 
type= 'Movie'
AND 
duration= (select max(duration) from netflix)
;

--6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE 
  CASE 
    WHEN date_added ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(date_added AS DATE)
    ELSE TO_DATE(date_added, 'Month DD, YYYY')
  END >= CURRENT_DATE - INTERVAL '5 years';


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
  title,
  type,
  director,
  CASE 
    WHEN array_length(string_to_array(director, ','), 1) = 1 THEN 'Solo Directed'
    ELSE 'Co-Directed'
  END AS directed_type
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';   --Ilike checks case sensitive. It will fetch rajiv and Rajiv both

--8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(split_part(duration, ' ', 1) AS INTEGER) > 5;

-- 9. Count the number of content items in each genre

select 
trim(unnest(string_to_array(listed_in,','))) as genre,    --Trim removes the spaces
count(*) as Total_Content
from netflix
group by 1
order by Total_Content Desc;

-- 10.Find each year and the average numbers of content release in India on netflix return top 5 year with highest avg content release
SELECT 
  release_year,
  COUNT(*) AS content_count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY content_count DESC
LIMIT 5;

--11. List all movies that are documentaries

select *, listed_in
from netflix
where type='Movie'
AND
listed_in ILIKE '%documentaries';

--12. Find all content without a director
select *
from netflix
where 
director isnull;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix
WHERE cast ILIKE '%Salman Khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
  AND type = 'Movie';

--table modification
ALTER TABLE netflix
RENAME COLUMN "cast" TO "cast1";

SELECT *
FROM netflix
WHERE cast1 ILIKE '%Salman Khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
  AND type = 'Movie';

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
unnest(string_to_array(cast1,',')) as actors,
count(*) as total_content
from netflix
where country ilike '%India%'
group by 1
order by 2 desc
limit 10;

-- 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

With new_table 
as
(
select 
*,
Case
when
description ilike '%kill%'
or
description ilike '%violence%'
then 'Bad_Content'
Else 'Good_Content'
End as category

from netflix
)
select category, 
count(*) as total_content
from new_table
group by 1
;