-- SCHEMAS of Netflix

CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;



------------------------------ Solutions of 15 business problems --------------------------------

-- Problem # 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1


-- Problem # 2. Find the most common rating for movies and TV shows

Select type, rating
From 
(
Select type, rating, Count(*),
Rank() OVER(PARTITION BY type Order BY 
COUNT (*) DESC ) as ranking
From netflix Group BY 1,2 
) as t1 
where ranking = 1


-- Problem # 3. List all movies released in a specific year (e.g., 2020)

SELECT type, title, release_year 
FROM netflix
WHERE type = 'Movie' 
AND
release_year = 2020


-- Problem # 4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ','))
	as new_country,
	COUNT(show_id) as total_content
	FROM netflix
	GROUP BY 1

ORDER BY 2 DESC
LIMIT 5


-- Problem # 5. Identify the longest movie

SELECT type, title, duration
FROM netflix
where
type = 'Movie'
AND
duration = (Select MAX(duration) from netflix)


-- Problem # 6. Find content added in the last 5 years

SELECT title, date_added, type FROM netflix
WHERE
TO_DATE(date_added, 'Month DD, YYYY') 
>= CURRENT_DATE - INTERVAL '5 years'


-- Problem # 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title, type, director
FROM
(SELECT *,
	UNNEST(STRING_TO_ARRAY(director, ','))
	as director_name FROM netflix )
WHERE 
	director_name = 'Rajiv Chilaka'


-- Problem # 8. List all TV shows with more than 5 seasons

SELECT title, duration FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5


 -- Problem # 9. Count the number of content items in each genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) 
	AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC
LIMIT 5;


-- Problem # 10. Find each year and the average numbers of content release by United States on netflix. Return top 5 year with highest avg content release !

SELECT country, release_year,
	COUNT(show_id) as total_release,
	ROUND( COUNT(show_id)::numeric/
		(SELECT COUNT(show_id) FROM netflix
		WHERE country = 'United States')::numeric * 100 
		,2) as avg_release
FROM netflix
WHERE country = 'United States' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


-- Problem # 11. List all movies that are documentaries

SELECT title, listed_in FROM netflix
WHERE type = 'Movie' 
AND
listed_in LIKE '%Documentaries'


-- Problem # 12. Find all content without a director

SELECT title, director FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Keanu Reeves' (JOHN WICK) appeared in last 10 years!

SELECT type, title, release_year FROM netflix
WHERE 
	casts LIKE '%Keanu Reeves%' -- JOHN WICK 
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- Problem # 14. Find the top 5 actors who have appeared in the highest number of movies produced in United States.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5



-- Problem 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

SELECT category,TYPE,
    COUNT(*) AS content_count
FROM (SELECT *, CASE 
   WHEN description ILIKE '%kill%' OR 
   description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2




