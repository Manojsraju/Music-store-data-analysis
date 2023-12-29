--							 Easy
-- 1) who is the senior most emolpyee based on job title ? 
SELECT *
FROM   employee
ORDER  BY levels DESC
LIMIT  1 

-- 2) which countries have the most invoices? 
SELECT Count(*)AS counts_as_per_country,
       billing_country,
       Row_number()
         OVER(
           ORDER BY Count(*) DESC)
FROM   invoice
GROUP  BY billing_country 

-- 3) What are top 3 values of total invoice?
SELECT invoice_id ,
       customer_id ,
       billing_country ,
       total ,
       Row_number() OVER(ORDER BY total DESC)
FROM  invoice limit 3
	
-- 4) Which city has the best customers? 
-- 	  We would like to throw a promotional Music Festival
-- 	  in the city we made the most money. Write a query that returns one 
-- 	  city that has the highest sum of invoice totals. Return both the city name & 
-- 	  sum of all invoice totals
SELECT ROUND(SUM(CAST(total AS NUMERIC)), 1) AS rounded_total,
       billing_city,
       ROW_NUMBER() OVER (ORDER BY ROUND(SUM(CAST(total AS NUMERIC)), 1) DESC) AS row_num
FROM invoice
GROUP BY billing_city;

-- 5) Who is the best customer? The customer who has spent the most money will
-- be declared the best customer. Write a query that returns the person who has
-- spent the most money
SELECT a.customer_id,
       a.first_name,
	   a.last_name,
       Sum(b.total)AS Total,
       Row_number()
         OVER(
           ORDER BY Sum(b.total) DESC)
FROM   customer a
       INNER JOIN invoice b
               ON a.customer_id = b.customer_id
GROUP  BY a.customer_id,
          a.first_name
		  limit 1 
		   
--	             		  Question Set 2 - Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music
--    listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT( a.email ),
               a.first_name,
               a.last_name,
               e.NAME
FROM   customer a
       INNER JOIN invoice b
               ON a.customer_id = b.customer_id
       INNER JOIN invoice_line c
               ON b.invoice_id = c.invoice_id
       INNER JOIN track d
               ON c.track_id = d.track_id
       INNER JOIN genre e
               ON d.genre_id = e.genre_id
WHERE  e.NAME = 'Rock'
ORDER  BY email 

-- 2) Let's invite the artists who have written the most rock music in our dataset. 
--  Write a query that returns the Artist name and total track count of the top 10
--  rock bands
SELECT a.name,
       b.artist_id,
       Count(b.artist_id)number_of_songs
FROM   track a
       INNER JOIN album b
               ON a.album_id = b.album_id
       INNER JOIN artist c
               ON b.artist_id = c.artist_id
       INNER JOIN genre d
               ON d.genre_id = a.genre_id
WHERE  d.name = 'Rock'
GROUP  BY a.name,
          b.artist_id
ORDER  BY number_of_songs DESC
LIMIT  10 

--3) Return all the track names that have a song length longer than the average song length. 
--   Return the Name and Milliseconds for each track. 
--   Order by the song length with the longest songs listed first
SELECT NAME,
       milliseconds
FROM   track
WHERE  milliseconds > (SELECT Avg(milliseconds)
                       FROM   track)
ORDER  BY milliseconds DESC 

--   						Question  - Advance
-- 2. We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
WITH popular_genre
     AS (SELECT a.billing_country,
                e.genre_id,
                Count(b.quantity)AS purchased,
                Row_number()
                  OVER(
                    partition BY billing_country
                    ORDER BY Count(b.quantity) DESC)
         FROM   invoice a
                INNER JOIN invoice_line b
                        ON a.invoice_id = b.invoice_id
                INNER JOIN track d
                        ON b.track_id = d.track_id
                INNER JOIN genre e
                        ON d.genre_id = e.genre_id
         GROUP  BY 1,
                   2)
SELECT *
FROM   popular_genre
WHERE  row_number <= 1 

--Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount
WITH customer_with_country
     AS (SELECT a.customer_id,
                a.first_name,
                a.last_name,
                a.country,
                Sum(b.total)                    AS total,
                Row_number()
                  OVER (
                    partition BY a.country
                    ORDER BY Sum(b.total) DESC) AS row_num
         FROM   customer a
                JOIN invoice b
                  ON a.customer_id = b.customer_id
         GROUP  BY 1,2,3,4)
SELECT *
FROM   customer_with_country
WHERE  row_num <= 1 

