
### Count of Customers and Count of movies, by store, that are not returned #####
SELECT c.store_id as store_id, COUNT(DISTINCT c.customer_id) as customer_cnt, COUNT(rental_id) as movies_rented
FROM rental r
LEFT JOIN customer c
ON r.customer_id = c.customer_id
WHERE return_date IS NULL
GROUP BY c.store_id;



#### Customer Name, Tranaction Count, Total amount paid, and average transaction amount for customers with avg txn over $4
### Sorted in Descnding order by total amount paid  ####
SELECT first_name, last_name, COUNT(payment_id) AS txns, SUM(amount) as total_paid, AVG(amount) AS avg_transaction
FROM payment p
LEFT JOIN customer c
ON p.customer_ID = c.customer_id
GROUP BY first_name, last_name
HAVING AVG(amount) > 4.00
ORDER BY total_paid DESC;


#### Histogram of Customer by Avg Transactions - Grouped
SELECT 
CASE WHEN a.avg_txn >= 5.25 THEN "Group 1"
WHEN a.avg_txn >= 4.75 AND a.avg_txn <= 5.25 THEN "Group 2"
WHEN a.avg_txn >= 4.25 AND a.avg_txn < 4.75 THEN "Group 3"
WHEN a.avg_txn >= 3.75 AND a.avg_txn < 3.25 THEN "Group 4"
ELSE "Group 5" END AS txn_group, 
COUNT(a.customer_id) as cust_cnt
FROM 
	(SELECT customer_id, Avg(Amount) as avg_txn
	FROM payment
	GROUP BY customer_id) a
GROUP BY txn_group;


#### Histogram of Customers by Avg Txn CTE Way###
with cst_txn as 
(SELECT customer_id, Avg(Amount) as avg_txn
FROM payment
GROUP BY customer_id)

SELECT
CASE WHEN a.avg_txn >= 5.25 THEN "Group 1"
WHEN a.avg_txn >= 4.75 AND a.avg_txn <= 5.25 THEN "Group 2"
WHEN a.avg_txn >= 4.25 AND a.avg_txn < 4.75 THEN "Group 3"
WHEN a.avg_txn >= 3.75 AND a.avg_txn < 3.25 THEN "Group 4"
ELSE "Group 5" END AS txn_group, 
COUNT(a.customer_id) as cust_cnt
FROM cst_txn
GROUP  BY txn_group;



### List of movies that contain trailers in the special features ####
SELECT title, special_features
FROM film f
WHERE lower(special_features) LIKE "%trailer%";



### List of actors in the appearing in films with trailers in the special features
SELECT first_name, last_name, COUNT(f.film_id) as film_cnt,
CASE WHEN COUNT(f.film_ID) >= 15 THEN "15 Films or More"
ELSE "Under 15 Films"
END AS Above_or_Below_15_Films
FROM film_actor fa
LEFT JOIN actor a
ON fa.actor_id = a.actor_id
LEFT JOIN film f
ON fa.film_id = f.film_id
WHERE lower(f.special_features) LIKE "%trailer%"
GROUP BY first_name, last_name
ORDER BY a.actor_id;




###  SELECT count of films and percent of total by rating ###
SELECT a.rating AS rating, a.cnt as cnt, a.cnt/b.total_cnt*100 as percent_of_total
FROM
(SELECT rating, COUNT(*) as cnt
	FROM film
	GROUP BY rating) a
CROSS JOIN
	(SELECT COUNT(*) as total_cnt
	FROM film) b
GROUP BY a.rating
ORDER BY a.cnt DESC;


### Window Verion Method of Above ###
SELECT rating, COUNT(*) as cnt, 100 * COUNT(*) / COUNT(*) OVER() as percent_of_total
from film
GROUP BY rating;