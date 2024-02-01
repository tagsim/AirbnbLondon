--1 count distinct id for duplicates
SELECT
	count(DISTINCT id)
FROM
	listingss;

SELECT
	count(id)
FROM
	listingss;
--2 count any duplicates - 0 
SELECT
	id
FROM
	listingss l
GROUP BY
	id
HAVING
	COUNT(*) > 1;
--3 - null value count - 0 null values
SELECT
	column_name,
	COUNT(*) - COUNT(column_name = '') AS null_count
FROM
	information_schema.columns
WHERE
	table_schema = 'public'
	AND table_name = 'listingss'
GROUP BY
	column_name
ORDER BY
	null_count DESC;
--4 null count - columns to be ignored (removed) neighbourhood group, license, last review, reviews per month

SELECT
	SUM(CASE WHEN neighbourhood_group = '' OR neighbourhood_group IS NULL THEN 1 ELSE 0 END) AS neighbourhood_group_blank_count,
	SUM(CASE WHEN license = '' OR license IS NULL THEN 1 ELSE 0 END) AS id_blank_count,
	SUM(CASE WHEN last_review = '' OR last_review IS NULL THEN 1 ELSE 0 END) AS last_review_count,
	-- Check for NULLS only
	SUM(CASE WHEN reviews_per_month IS NULL THEN 1 ELSE 0 END) AS reviews_permonth_count,
	-- Check for NULLS only
	SUM(CASE WHEN description = '' OR description IS NULL THEN 1 ELSE 0 END) AS description_count,
	SUM(CASE WHEN host_name = '' OR host_name IS NULL THEN 1 ELSE 0 END) AS host_name_count,
FROM
	listingss l;

SELECT
	SUM(CASE WHEN number_of_reviews_ltm IS NULL THEN 1 ELSE 0 END) AS number_of_reviews_ltm_count
FROM
	listingss l;

ALTER TABLE listingss
DROP COLUMN neighbourhood_group;

ALTER TABLE listingss
DROP COLUMN last_review;

ALTER TABLE listingss
DROP COLUMN reviews_per_month;

ALTER TABLE listingss
DROP COLUMN license;

SELECT
	*
FROM
	listingss;
--5 removal of missing 21 descriptions and 5 host names from these columns


SELECT
	count(*)
FROM
	listingss l
WHERE
	description = ''
	OR description IS NULL;

DELETE
FROM
	listingss
WHERE
	description = ''
	OR description IS NULL;

SELECT
	count(*)
FROM
	listingss l
WHERE
	host_name = ''
	OR description IS NULL;

DELETE
FROM
	listingss
WHERE
	host_name = ''
	OR description IS NULL;
--6 select * column head limit 3, for future export after EDA
SELECT
	*
FROM
	listingss l
LIMIT 3;
-- 7 id analysis 69,325 unique, no id showing more than once for each entry
SELECT
	DISTINCT count(id)
FROM
	listingss l
	--GROUP BY id;
	--host id analysis
SELECT
	id,
	count(host_id) AS hostidcount
FROM
	listingss l
GROUP BY
	id,
	host_id
ORDER BY
	hostidcount DESC;
--host name
SELECT
	DISTINCT count(host_name)
FROM
	listingss l;
--host id and name count to determine top 20 frequent hosts: 1st Veronica 285 counts 20th Ivy 76 counts
SELECT
	host_id ,
	host_name,
	count(host_name) AS hostnamecount
FROM
	listingss l
GROUP BY
	host_id,
	host_name
ORDER BY
	hostnamecount DESC;
--borough and number of hosts in each area - Westminster top of 20, Merton 20th:
SELECT
	neighbourhood,
	count(host_id)
FROM
	listingss l
GROUP BY
	neighbourhood
ORDER BY
	count(host_id) DESC;
--neighbourhood top 20, with 1st Westminster, 20th Richmond Upon Thames
SELECT
	neighbourhood,
	count(neighbourhood) AS countneighbourhood
FROM
	listingss l
GROUP BY
	neighbourhood
ORDER BY
	countneighbourhood DESC;
--lat and long analysis - 2 differing formats
SELECT
	longitude,
	count(longitude) AS countlong
FROM
	listingss l
GROUP BY
	1
ORDER BY
	countlong DESC;

SELECT
	latitude,
	count(latitude)
FROM
	listingss l
GROUP BY
	latitude
ORDER BY
	count(latitude) DESC;
--room type analysis:
SELECT
	room_type,
	count(room_type) AS roomtypecount
FROM
	listingss l
GROUP BY
	1
ORDER BY
	roomtypecount DESC ;
--pricing analysis
SELECT
	room_type,
	round(avg(price),
	2) AS avgprice
FROM
	listingss l
GROUP BY
	room_type
ORDER BY
	avg(price) DESC;
--avg price per neighbourhood
SELECT
	neighbourhood,
	round(avg(price),
	2) AS avgprice
FROM
	listingss l
GROUP BY
	neighbourhood
ORDER BY
	avg(price) DESC;
--Southwark has most frequent count for private rooms above the highest average price - for hotel, also listed Westminster  entire home and Brent private room:
SELECT
	neighbourhood,
	count(neighbourhood),
	room_type,
	price
FROM
	listingss l
WHERE
	price > 245.84
GROUP BY
	neighbourhood,
	room_type,
	price
ORDER BY
	count(neighbourhood) DESC;
--reviews - westminster has most reviews of boroughs
SELECT
	neighbourhood,
	count(number_of_reviews) AS reviewcount
FROM
	listingss l
GROUP BY
	neighbourhood
ORDER BY
	reviewcount DESC;
-- description influence on avaliability
SELECT
	description,
	availability_365
FROM
	listingss
GROUP BY
	description ,
	availability_365
ORDER BY
	availability_365 DESC;
--average minimum night for all bookings as 5.9
SELECT
	ROUND(avg(minimum_nights),0) AS minavg,
	min(minimum_nights) AS minmin,
	max(minimum_nights) AS maxmin
FROM
	listingss l;
--avg minimum night by room type
SELECT
	room_type,
	ROUND(avg(minimum_nights),0) AS minavgnight
FROM
	listingss l
GROUP BY
	room_type
ORDER BY
	minavgnight;

--availability between 10-365 days
SELECT
	host_id,
	host_name,
	avg(availability_365)
FROM
	listingss l
WHERE
	availability_365 <= 365
	AND availability_365 > 10
ORDER BY
	availability_365 ASC;

SELECT
	host_id,
	host_name,
	availability_365
FROM
	listingss l
WHERE
	availability_365 <= 365
	AND availability_365 > 30
ORDER BY
	availability_365 ASC;
--Youtube video exploratory data questions:

SELECT
	*
FROM
	listingss l
LIMIT
--keeping in mind periods in which the host does not have the property available for booking , minimum availability being 30 days- between 30 and 365
--if booked every night
SELECT
	host_id,
	host_name,
	room_type,
	price,
	availability_365,
	number_of_reviews,
	(price * (availability_365)) AS projincome
FROM
	listingss l
WHERE
	availability_365 <= 365
	AND availability_365 > 30
	--AND number_of_reviews > 5
GROUP BY
	1,
	2,
	3,
	4,
	5,
	6
ORDER BY
	projincome DESC
LIMIT 30;
ORDER BY
projincome DESC ;
--highest earning projection
SELECT
	id,
	host_id ,
	host_name ,
	(365- availability_365) AS bookedout,
	price,
	(price * (365-availability_365)) AS projectedincome
FROM
	listingss l
WHERE
	availability_365 > 0
GROUP BY
	1,
	2,
	3,
	4,
	5
ORDER BY
	projectedincome DESC
LIMIT 20;
--description of property
SELECT
	description,
	number_of_reviews
FROM
	listingss
WHERE
	description LIKE '%clean%'
ORDER BY
	number_of_reviews DESC;

SELECT
	description,
	number_of_reviews
FROM
	listingss
WHERE
	description LIKE '%central%'
ORDER BY
	number_of_reviews DESC;

SELECT
	host_id ,
	host_name,
	count(calculated_host_listings_count) AS countcalc
FROM
	listingss l
GROUP BY
	host_id,
	host_name
ORDER BY
	countcalc DESC;

SELECT
	id,
	host_id ,
	host_name,
	(365-availability_365) AS bookednights,
	(price *(365-availability_365)) AS projectincome
FROM
	listingss l
WHERE
	host_name = 'Veronica'
	AND host_id = '28820321'
	AND availability_365 > 300
ORDER BY
	projectincome DESC;
--youtube video 2: EDA
--What can I gather from each host and neighbourhood: Host Veronica with properties in Harrow, Waltham Forest, Haringey, Barnet and a number of other properties 
--hold the max listings
SELECT
	host_id ,
	host_name,
	neighbourhood,
	max(calculated_host_listings_count) AS maxcalclisting
FROM
	listingss l
GROUP BY
	1,
	2,
	3
ORDER BY
	maxcalclisting DESC
LIMIT 10;
--2.What can we learn from room type, and max prices based on area:
SELECT
	neighbourhood,
	room_type,
	max(price)
FROM
	listingss l
GROUP BY
	1,
	2
ORDER BY
	max(price) DESC
LIMIT 10;
--3. what can we learn from neighbourhood and reviews (link to number of listings)
SELECT
	neighbourhood,
	max(number_of_reviews)
FROM
	listingss l
GROUP BY
	neighbourhood
ORDER BY
	max(number_of_reviews) DESC;
--4.what can we learn from host listings and reviews, not a strong correlation
SELECT
	neighbourhood,
	calculated_host_listings_count,
	number_of_reviews
FROM
	listingss l
ORDER BY
	calculated_host_listings_count DESC
	--5. what can we learn from price and reviews - no strong correlation
SELECT
	price,
	number_of_reviews,
	number_of_reviews_ltm
FROM
	listingss l
ORDER BY
	price DESC;
--6. what can we learn from popular room type
SELECT
	room_type ,
	count(room_type) AS countroomtype
FROM
	listingss l
GROUP BY
	room_type
ORDER BY
	countroomtype DESC;
--7. busiest host,review   and why? Busiest in central London, private room or entire house which is preferred
SELECT
	host_id,
	host_name,
	price,
	room_type,
	neighbourhood,
	number_of_reviews
FROM
	listingss l
ORDER BY
	number_of_reviews DESC;
--8. Which host is charging the most- Bikash £25,000 for a private room followed by Baronial Pads, Smart Solutions,
-- however it is typically for entire home/apt
SELECT
	host_id ,
	host_name,
	room_type,
	max(price) AS maxprice
FROM
	listingss l
GROUP BY
	1,
	2,
	3
ORDER BY
	maxprice DESC
LIMIT 30;
--9.What is the difference in min nights by areas:
SELECT
	neighbourhood ,
	room_type ,
	minimum_nights,
	count(minimum_nights)
FROM
	listingss l
GROUP BY
	1,
	2,
	3
ORDER BY
	count(minimum_nights) DESC;
--10. which are the most popular neighbourhoods top 5 = Westminster, T Hamlets, Hackney, Camden, Kensington Chelsea
SELECT
	neighbourhood,
	count(neighbourhood) AS neighbourhoodcount,
	ROUND(100.0 * count(neighbourhood) / SUM(count(neighbourhood)) OVER(),
	2) AS percentage
FROM
	listingss l
GROUP BY
	1
ORDER BY
	percentage DESC;
--11. Which room types are most popular in most popular neighbourhoods, count and percentage room type
SELECT
	neighbourhood,
	room_type,
	count(room_type) AS roomcount,
	round(100 * count(room_type)/ sum(count(room_type)) OVER (PARTITION BY room_type),
	2) AS percentageroom
FROM
	listingss l
WHERE
	neighbourhood IN ('Westminster', 'Tower Hamlets', 'Hackney', 'Camden', 'Kensington and Chelsea')
GROUP BY
	1,
	2
ORDER BY
	roomcount DESC;
-- Kensington and Chelsea has 46.67 perce of rooms (Hotels), Westminster 32.12 Hotel, follwoed by 31.97 shared room
SELECT
	neighbourhood,
	room_type,
	COUNT(room_type) AS roomcount,
	ROUND(100.0 * COUNT(room_type) / SUM(COUNT(room_type)) OVER (PARTITION BY room_type),
	2) AS percentage
FROM
	listingss l
WHERE
	neighbourhood IN ('Westminster', 'Tower Hamlets', 'Hackney', 'Camden', 'Kensington and Chelsea')
GROUP BY
	1,
	2
ORDER BY
	percentage DESC;
--12. export dataset:
SELECT
	*
FROM
	listingss l ;
