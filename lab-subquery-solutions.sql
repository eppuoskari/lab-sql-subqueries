USE sakila;

# Write SQL queries to perform the following tasks using the Sakila database:
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT film_id 
FROM film
WHERE title = "Hunchback Impossible";

SELECT COUNT(*) AS copies
FROM inventory
WHERE film_id = (SELECT film_id 
	FROM film
	WHERE title = "Hunchback Impossible");

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT AVG(length)
FROM film;

SELECT title,
	length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT fa.actor_id
FROM film_actor AS fa
LEFT JOIN film AS f
	ON fa.film_id = f.film_id
WHERE f.title = "Alone Trip";

SELECT * 
FROM actor
WHERE actor_id IN (SELECT fa.actor_id
	FROM film_actor AS fa
	LEFT JOIN film AS f
		ON fa.film_id = f.film_id
	WHERE f.title = "Alone Trip");
    
# Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
--    Identify all movies categorized as family films.
SELECT category_id FROM category
WHERE name = 'Family';

SELECT film_id FROM film_category
WHERE category_id = (SELECT category_id FROM category
	WHERE name = 'Family');
    
SELECT * FROM film
WHERE film_id IN (SELECT film_id FROM film_category
	WHERE category_id = (SELECT category_id FROM category
		WHERE name = 'Family')) ;

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
--    To use joins, you will need to identify the relevant tables and their primary and foreign keys.
# Join
SELECT first_name,
	last_name,
    email
FROM customer AS c
LEFT JOIN address AS a
	ON c.address_id = a.address_id
LEFT JOIN city AS ci
	ON a.city_id = ci.city_id
LEFT JOIN country AS co
	ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

# Subquery
SELECT country_id FROM country
WHERE country = 'Canada';

SELECT city_id FROM city
WHERE country_id = (SELECT country_id FROM country
	WHERE country = 'Canada');
    
SELECT address_id FROM address
WHERE city_id IN (SELECT city_id FROM city
	WHERE country_id = (SELECT country_id FROM country
		WHERE country = 'Canada'));
        
SELECT first_name,
	last_name,
    email
FROM customer
WHERE address_id IN (SELECT address_id FROM address
	WHERE city_id IN (SELECT city_id FROM city
		WHERE country_id = (SELECT country_id FROM country
			WHERE country = 'Canada')));

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has 
--    acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different 
--    films that he or she starred in.
SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT film_id FROM film_actor
WHERE actor_id = (SELECT actor_id
	FROM film_actor
	GROUP BY actor_id
	ORDER BY COUNT(*) DESC
	LIMIT 1);
    
SELECT title FROM film
WHERE film_id in (SELECT film_id FROM film_actor
	WHERE actor_id = (SELECT actor_id
		FROM film_actor
		GROUP BY actor_id
		ORDER BY COUNT(*) DESC
		LIMIT 1));


-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to 
--    find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT customer_id
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;

SELECT rental_id FROM payment
WHERE customer_id = (SELECT customer_id
	FROM payment
	GROUP BY customer_id
	ORDER BY SUM(amount) DESC
	LIMIT 1);

SELECT inventory_id FROM rental
WHERE rental_id IN (SELECT rental_id FROM payment
	WHERE customer_id = (SELECT customer_id
		FROM payment
		GROUP BY customer_id
		ORDER BY SUM(amount) DESC
		LIMIT 1));
        
SELECT film_id FROM inventory
WHERE inventory_id IN (SELECT inventory_id FROM rental
	WHERE rental_id IN (SELECT rental_id FROM payment
		WHERE customer_id = (SELECT customer_id
			FROM payment
			GROUP BY customer_id
			ORDER BY SUM(amount) DESC
			LIMIT 1)));
            
SELECT DISTINCT(title) FROM film
WHERE film_id IN (SELECT film_id FROM inventory
	WHERE inventory_id IN (SELECT inventory_id FROM rental
		WHERE rental_id IN (SELECT rental_id FROM payment
			WHERE customer_id = (SELECT customer_id
				FROM payment
				GROUP BY customer_id
				ORDER BY SUM(amount) DESC
				LIMIT 1))));

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
--    You can use subqueries to accomplish this.
SELECT SUM(amount) AS total_amount
FROM payment
GROUP BY customer_id;

SELECT AVG(total_amount)
FROM (SELECT SUM(amount) AS total_amount
	FROM payment
	GROUP BY customer_id) AS subquery;
    
SELECT 
    customer_id,
    SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_amount) 
    FROM (
        SELECT SUM(amount) AS total_amount
        FROM payment
        GROUP BY customer_id) AS subquery
);