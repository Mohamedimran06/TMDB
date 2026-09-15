USE TBMD;

-- Q1: Action movies released after 2015
SELECT DISTINCT m.title, m.release_date
FROM movies AS m
JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
JOIN genres AS g ON g.genre_id = mg.genre_id
WHERE g.genre_name = 'Action' AND m.release_date > '2015-12-31'
ORDER BY m.release_date, m.title;

-- Q2: Top 10 highest-grossing movies and their genres
SELECT m.title, m.revenue,
       GROUP_CONCAT(DISTINCT g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres
FROM movies AS m
LEFT JOIN movie_genres AS mg ON mg.movie_id = m.movie_id
LEFT JOIN genres AS g ON g.genre_id = mg.genre_id
WHERE m.revenue IS NOT NULL AND m.revenue > 0
GROUP BY m.movie_id, m.title, m.revenue
ORDER BY m.revenue DESC
LIMIT 10;

-- Q3: Average budget and revenue by genre
SELECT g.genre_name,
       AVG(NULLIF(m.budget, 0)) AS average_budget,
       AVG(NULLIF(m.revenue, 0)) AS average_revenue
FROM genres AS g
JOIN movie_genres AS mg ON mg.genre_id = g.genre_id
JOIN movies AS m ON m.movie_id = mg.movie_id
GROUP BY g.genre_id, g.genre_name
ORDER BY average_revenue DESC;

-- Q4: Top 10 actors by number of movies
SELECT actor_name, COUNT(DISTINCT movie_id) AS movie_count
FROM `cast`
WHERE actor_name IS NOT NULL AND actor_name <> 'Unknown'
GROUP BY actor_name
ORDER BY movie_count DESC, actor_name
LIMIT 10;

-- Q5: Directors who directed more than 3 movies
SELECT person_name AS director, COUNT(DISTINCT movie_id) AS movie_count
FROM crew
WHERE job = 'Director'
GROUP BY person_id, person_name
HAVING COUNT(DISTINCT movie_id) > 3
ORDER BY movie_count DESC, director;

-- Q6: Top 10 most frequently used keywords
SELECT keyword_name, COUNT(DISTINCT movie_id) AS keyword_count
FROM movie_keywords
WHERE keyword_name IS NOT NULL AND keyword_name <> 'Unknown'
GROUP BY keyword_id, keyword_name
ORDER BY keyword_count DESC, keyword_name
LIMIT 10;

-- Q7: Movies above average budget but below average revenue
SELECT title, budget, revenue
FROM movies
WHERE budget > (SELECT AVG(NULLIF(budget, 0)) FROM movies)
  AND revenue < (SELECT AVG(NULLIF(revenue, 0)) FROM movies)
ORDER BY budget DESC, revenue;

-- Q8: Actors in a movie directed by Christopher Nolan
SELECT DISTINCT c.actor_name, m.title
FROM `cast` AS c
JOIN movies AS m ON m.movie_id = c.movie_id
JOIN crew AS cr ON cr.movie_id = c.movie_id
WHERE cr.job = 'Director' AND cr.person_name = 'Christopher Nolan'
ORDER BY c.actor_name, m.title;

-- Q9: Genre with the highest average rating, considering genres with at least 20 movies
SELECT g.genre_name,
       COUNT(DISTINCT m.movie_id) AS movie_count,
       AVG(NULLIF(m.vote_average, 0)) AS average_rating
FROM genres AS g
JOIN movie_genres AS mg ON mg.genre_id = g.genre_id
JOIN movies AS m ON m.movie_id = mg.movie_id
WHERE m.vote_average IS NOT NULL AND m.vote_average > 0
GROUP BY g.genre_id, g.genre_name
HAVING COUNT(DISTINCT m.movie_id) >= 20
ORDER BY average_rating DESC
LIMIT 1;

-- Q10: Top 10 movies by number of keyword tags
SELECT m.title, COUNT(DISTINCT mk.keyword_id) AS keyword_count
FROM movies AS m
JOIN movie_keywords AS mk ON mk.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY keyword_count DESC, m.title
LIMIT 10;
