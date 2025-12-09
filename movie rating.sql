CREATE DATABASE movierating;
USE movierating;

CREATE TABLE movie
(mID INT,
title VARCHAR(50),
year INT,
director VARCHAR(100));

CREATE TABLE reviewer
(rID INT,
name VARCHAR(50));

CREATE TABLE rating
(rID INT,
mID INT,
stars INT,
ratingDate DATE);

INSERT INTO movie 
(mID, title,year,director) VALUES 
(101,'Gone with the wind',1939,'Victor Fleming'),
(102,'Star wars',1977,'George Lucas'),
(103,'The sound of music',1965,'Robert Wise'),
(104,'E.T.',1982,'Steven Spielberg'),
(105,'Titanic',1997,'James Cameron'),
(106,'Snow White',1937,NULL),
(107,'Avatar',2009,'James Cameron'),
(108,'Raiders of a lost Ark',1981,'Steven Spielberg');

INSERT INTO reviewer
(rID,name) VALUES
(201,'Sara Martinez'),
(202,'Daniel Lewis'),
(203,'Brittany Harris'),
(204,'Mike Anderson'),
(205,'Chris Jackson'),
(206,'Elizibeth Thomas'),
(207,'James Cameron'),
(208,'Ashley White');

INSERT INTO Rating
(rID,mID,stars,ratingDate) VALUES
(201,101,2,'2011-01-22'),
(201,101,4,'2011-01-27'),
(202,106,4,NULL),
(203,103,2,'2011-01-20'),
(203,108,4,'2011-01-12'),
(203,108,2,'2011-01-30'),
(204,101,3,'2011-01-09'),
(205,103,3,'2011-01-27'),
(205,104,2,'2011-01-22'),
(205,108,4,NULL),
(206,107,3,'2011-01-15'),
(206,106,5,'2011-01-19'),
(207,107,5,'2011-01-20'),
(208,104,3,'2011-01-02');

/* Find the titles of all movies directed by Steven Spielberg.*/
SELECT title
FROM movie 
WHERE director IN (SELECT director FROM movie WHERE director ='Steven Spielberg');

/*Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.*/
SELECT year
FROM movie,Rating
WHERE movie.mID = Rating.mID AND stars > 3
GROUP BY year
ORDER BY year;

/* Find the titles of all movies that have no ratings.*/
SELECT title
FROM movie
WHERE mID NOT IN (SELECT mID FROM Rating);

/* Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.*/
SELECT name
FROM reviewer, Rating
WHERE  reviewer.rID = Rating.rID AND ratingDate IS NULL;

/* Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.*/
SELECT name, title, stars, DATE (ratingDate) AS reviewDate
FROM reviewer,movie, Rating
WHERE movie.mID = Rating.mID AND reviewer.rID = Rating.rID 
ORDER BY name,title, stars, DATE(ratingDate);

/* For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.*/
SELECT reviewer.name, movie.title
FROM Rating R1
JOIN Rating R2
ON R1.rID = R2.rID AND R1.mID = R2.mID AND R1.ratingDate > R2.ratingDate AND R1.stars > R2.stars
JOIN movie ON R1.mID = movie.mID
JOIN reviewer ON R1.rID = reviewer.rID;

/* For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.*/
SELECT title, MAX(stars)
FROM movie, Rating
WHERE movie.mID = Rating.mID
GROUP BY title
ORDER BY title;

/* For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.*/
SELECT title, M.mx - M.mn
	FROM (SELECT title, MAX(stars) as mx, MIN(stars) as mn
	FROM movie, Rating
	WHERE movie.mID = Rating.mID
	GROUP BY title) M
	ORDER BY M.mx - M.mn DESC, title ASC;
    
/* Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)
*/
SELECT AVG(BF.avgbf1980) - AVG(AF.avgaf1980)
FROM
(SELECT title,AVG(stars) AS avgbf1980
FROM Rating,movie
WHERE movie.mID IN (SELECT mID FROM Rating) AND Rating.mID = movie.mID AND year < 1980
GROUP BY title) BF,
(SELECT title,AVG(stars) AS avgaf1980
FROM Rating,movie
WHERE movie.mID IN (SELECT mID FROM Rating) AND Rating.mID = movie.mID AND year > 1980
GROUP BY title) AF;

/* Find the names of all reviewers who rated Gone with the Wind.*/
SELECT DISTINCT name
FROM Rating
JOIN reviewer
ON Rating.rID = reviewer.rID AND mID = 101;

/* For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.*/
SELECT DISTINCT reviewer.name, movie.title, Rating.stars
FROM movie
JOIN reviewer
ON movie.director = reviewer.name
JOIN Rating ON movie.mID = Rating.mID AND Rating.rID = reviewer.rID;

/* Return all reviewer names and movie names together in a single list, alphabetized. 
(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
*/
SELECT DISTINCT R1.name as reviewer1, R2.name as reviewer2
FROM Rating rat1
JOIN Rating rat2
ON rat1.rID != rat2.rID AND rat1.mID = rat2.mID
JOIN reviewer R1 ON R1.rID = rat1.rID
JOIN reviewer R2 ON R2.rID = rat2.rID;

/* Find the titles of all movies not reviewed by Chris Jackson.*/
SELECT title 
FROM movie 
WHERE mID NOT IN (SELECT  mID 
FROM Rating
WHERE rID = (SELECT rID 
FROM reviewer
WHERE name = 'Chris Jackson'));

/* For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
For each pair, return the names in the pair in alphabetical order.
*/
SELECT DISTINCT R1.name as reviewer1, R2.name as reviewer2
FROM Rating rat1
JOIN Rating rat2
ON rat1.rID != rat2.rID AND rat1.mID = rat2.mID
JOIN reviewer R1 ON R1.rID = rat1.rID
JOIN reviewer R2 ON R2.rID = rat2.rID
WHERE R1.name < R2.name
ORDER BY reviewer1, reviewer2;

/* For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.*/
SELECT DISTINCT name,title, stars
FROM Rating
JOIN reviewer ON reviewer.rID = Rating.rID
JOIN movie ON movie.mID = Rating.mID
WHERE stars = (SELECT MIN(stars)
FROM Rating)
ORDER BY name,title,stars;

/* List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.*/
SELECT title, AVG(stars) 
From Rating
JOIN movie ON movie.mID = Rating.mID
GROUP BY title
HAVING AVG(stars) 
ORDER BY AVG(stars) DESC, title ASC;

/* Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)*/
SELECT name
FROM reviewer
WHERE rID IN (SELECT rID
FROM Rating
GROUP BY rID
HAVING COUNT(stars) = 3);

/* Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. 
Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
*/
SELECT title, director
FROM movie
WHERE director IN (SELECT director
FROM movie
GROUP BY director
HAVING COUNT(director) > 1)
ORDER BY director ASC, title;

/* Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
(Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
*/
SELECT title, AVG(stars)
FROM movie 
JOIN Rating
ON movie.mID = Rating.mID
GROUP BY title
HAVING AVG(stars) = (SELECT MAX(S.AVGS)
FROM 
(SELECT  AVG(stars) AS AVGS
FROM Rating
GROUP BY mID) S);

/* Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)
*/
SELECT title, AVG(stars)
FROM movie 
JOIN Rating
ON movie.mID = Rating.mID
GROUP BY title
HAVING AVG(stars) = (SELECT MIN(S.AVGS)
FROM 
(SELECT  AVG(stars) AS AVGS
FROM Rating
GROUP BY mID) S);

/* For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. 
Ignore movies whose director is NULL.
*/
SELECT DISTINCT M.director, M.title, MAX(stars) 
FROM movie M
JOIN Rating R
ON M.mID = R.mID 
GROUP BY title, director
HAVING MAX(stars) IN (SELECT MAX(stars)
FROM Rating R
JOIN MOVIE M2  ON  M2.mID = R.mID AND M.director = M2.director) AND director IS NOT NULL 
ORDER BY director;

/* Add the reviewer Roger Ebert to your database, with an rID of 209.*/
INSERT INTO Reviewer VALUES (209, 'Roger Ebert');

/* For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)*/
UPDATE movie
SET year = year + 25 
WHERE mID IN (SELECT mID FROM Rating Where stars > 4);

/* Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.*/
DELETE FROM Rating 
WHERE mID IN (SELECT mID FROM movie 
WHERE year < 1970 OR year > 2000)
AND stars < 4;

