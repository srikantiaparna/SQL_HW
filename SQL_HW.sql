USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT 
       first_name AS "First Name", 
       last_name AS "Last Name"
FROM   sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT 
     UPPER(CONCAT(first_name ,' ' ,last_name)) AS "Actor Name"
FROM sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
    -- What is one query would you use to obtain this information?
 
SELECT 
      actor_id AS "Actor ID", 
      first_name AS "First Name", 
      last_name AS "Last Name" 
FROM  sakila.actor
WHERE 
      first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
      actor_id AS "Actor ID", 
      first_name AS "First Name", 
      last_name AS "Last Name" 
FROM  sakila.actor
WHERE 
	  last_name LIKE '%GEN%';


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT 
      actor_id AS "Actor ID", 
      last_name AS "Last Name",
      first_name AS "First Name"
FROM  sakila.actor
WHERE 
	  last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT 
      country_id AS "Country ID", 
      country AS "Country Name"
FROM  country
WHERE 
      country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
	-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the 
    -- type BLOB, as the difference between it and VARCHAR are significant).
 
ALTER TABLE sakila.actor
ADD COLUMN description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE sakila.actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
      last_name AS "Last Name",
      COUNT(last_name) AS "Number of Actors"
FROM  sakila.actor
GROUP BY 
      last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that 
    -- are shared by at least two actors
SELECT 
      last_name AS "Last Name",
      COUNT(last_name) AS "Number of Actors"
FROM  sakila.actor
GROUP BY 
      last_name
HAVING COUNT(last_name) > 1;
 
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE sakila.actor
SET first_name = 'HARPO'
WHERE 
      actor_id = 172
  AND first_name = 'GROUCHO' 
  AND last_name = 'WILLIAMS';
      

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after
    -- all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

--  Turn safe updates on
SET SQL_SAFE_UPDATES = 1;

UPDATE  sakila.actor
SET  first_name = 'GROUCHO'
WHERE 
      actor_id = 172
  AND first_name = 'HARPO';  
    


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESCRIBE sakila.address;
-- OR
SHOW CREATE TABLE sakila.address;

/** Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html **/

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT 
      s.first_name AS "First Name", 
      s.last_name AS "Last Name", 
      a.address AS "Address1", 
      a.address2 AS "Address2",
      a.district AS "District", 
      c.city AS "City", 
      a.postal_code AS "Postal Code"
FROM sakila.city c
INNER JOIN  sakila.address a
ON 
 c.city_id = a.city_id
INNER JOIN sakila.staff s
ON 
  a.address_id = s.address_id;
  


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT 
       s.staff_id AS "Staff ID", 
       s.first_name AS "First Name", 
       s.last_name AS "Last Name", 
       p.amount AS "Amount", 
       p.payment_date AS "Payment Date"
FROM   sakila.staff s
JOIN   sakila.payment p
ON 
       s.staff_id = p.staff_id
WHERE 
       p.payment_date BETWEEN '2005-08-01' AND '2005-08-31';
  
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT 
       f.title AS "Film Title", 
       COUNT(fa.actor_id) AS "Number of Actors"
FROM   sakila.film f
INNER JOIN 
       sakila.film_actor fa
    ON f.film_id = fa.film_id
GROUP BY 
       f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

-- JOINS

SELECT 
	   f.title AS "Film Title",
	   COUNT(f.film_id) AS "Number of Copies"
FROM   sakila.film f
INNER JOIN 
	   sakila.inventory i
   ON  f.film_id = i.film_id
WHERE 
       f.title = 'Hunchback Impossible';

-- Sub Query

SELECT f.title AS "Film Title",
	(
	SELECT COUNT(*) 
	FROM sakila.inventory i
	WHERE f.film_id = i.film_id
	) AS 'Number of Copies'
FROM sakila.film f
WHERE 
     f.title = "Hunchback Impossible";


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
    -- List the customers alphabetically by last name:

SELECT  
     c.first_name AS "First Name",
     c.last_name AS "Last Name", 
     SUM(p.amount) AS "Total Amount Paid"
FROM sakila.customer c
JOIN sakila.payment p
  ON c.customer_id = p.customer_id
GROUP BY 
     c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
    -- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
    -- of movies starting with the letters K and Q whose language is English.
    
SELECT 
     title AS "Film Title"
FROM sakila.film f
WHERE language_id =
   (
	SELECT language_id
	FROM sakila.language l
	WHERE l.name LIKE '%English%' 
    )
AND f.title LIKE "K%" 
OR f.title LIKE "Q%";
 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
       first_name AS "First Name", 
	   last_name AS "Last Name"
FROM   sakila.actor a
WHERE
       a.actor_id IN 
    (
		  SELECT actor_id
		  FROM   sakila.film_actor fa
		  WHERE  
                 fa.film_id = 
	    (
				SELECT film_id
				FROM   sakila.film f
				WHERE 
					   title = 'Alone Trip'
		)
 );

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
	-- of all Canadian customers. Use joins to retrieve this information.
-- Sub Query
SELECT 
     first_name AS "First Name", 
     last_name AS "Last Name", 
     email AS "Email"
FROM sakila.customer   
WHERE address_id IN 
(
	SELECT address_id
	FROM sakila.address
	WHERE city_id IN
    (
		SELECT city_id
		FROM sakila.city
		WHERE country_id =
			(
            SELECT country_id
			FROM sakila.country
			WHERE country ='Canada'
            )
	 )
);

-- Joins
SELECT 
     first_name AS "First Name", 
     last_name AS "Last Name", 
     email AS "Email"
FROM sakila.customer c
JOIN sakila.address a
  ON c.address_id = a.address_id
JOIN sakila.city ci
  ON a.city_id = ci.city_id
JOIN sakila.country co
  ON ci.country_id = co.country_id
WHERE co.country ='Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
    -- Identify all movies categorized as family films.

SELECT 
     f.title AS "Film Title",
     f.description AS "Film Description"
FROM sakila.film f
WHERE 
     f.film_id IN 
(
	SELECT film_id
	FROM film_category fc
	WHERE fc.category_id = 
      (
		SELECT category_id
		FROM sakila.category c
		WHERE c.name = 'Family'
	  )
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
     title AS "Movie Title",
     COUNT(r.rental_id) AS "Frequently Rented Movies"
FROM sakila.film f
JOIN sakila.inventory i
ON f.film_id = i.film_id
JOIN sakila.rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT 
     s.store_id, 
     SUM(amount) AS 'Revenue'
FROM sakila.payment p
JOIN sakila.rental r
  ON (p.rental_id = r.rental_id)
JOIN sakila.inventory i
  ON (i.inventory_id = r.inventory_id)
JOIN sakila.store s
  ON (s.store_id = i.store_id)
GROUP BY s.store_id; 


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ct.country
FROM sakila.store s
JOIN sakila.address a
ON s.address_id = a.address_id
JOIN sakila.city c
ON a.city_id = c.city_id
JOIN sakila.country ct
ON c.country_id = ct.country_id


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
    -- tables: category, film_category, inventory, payment, and rental.)

SELECT 
     c.name AS "Genre", 
     SUM(amount) AS "Gross Revenue"
FROM sakila.category c
JOIN sakila.film_category fc
ON c.category_id = fc.category_id
JOIN sakila.inventory i
ON fc.film_id = i.film_id
JOIN sakila.rental r
ON i.inventory_id = r.inventory_id
JOIN sakila.payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(amount) DESC 
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
    -- Use the solution from the problem above to create a view. If you have not solved 7h, you can substitute 
    -- another query to create a view.
    
CREATE VIEW genre_gross_revenue_vw
AS
SELECT 
     c.name AS "Genre", 
     SUM(amount) AS "Gross Revenue"
FROM sakila.category c
JOIN sakila.film_category fc
  ON c.category_id = fc.category_id
JOIN sakila.inventory i
  ON fc.film_id = i.film_id
JOIN sakila.rental r
  ON i.inventory_id = r.inventory_id
JOIN sakila.payment p
  ON r.rental_id = p.rental_id
GROUP BY 
     c.name
ORDER BY SUM(amount) DESC 
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * 
FROM genre_gross_revenue_vw;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW IF EXISTS genre_gross_revenue_vw;