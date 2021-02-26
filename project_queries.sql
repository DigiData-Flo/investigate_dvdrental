
/*-- Query Question 1  ----*/
WITH ca AS (
	SELECT ca.name, ca.category_id
		FROM category ca
		WHERE name in ('Animation','Children','Classics','Comedy','Family','Music')
)
SELECT f.title,	ca.name, COUNT(r.rental_id)
FROM ca
JOIN film_category fc ON ca.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r. inventory_id
GROUP BY 1,2
ORDER BY 3 DESC;


/*-- Query Question 2  ----*/
WITH
	ca AS (
		SELECT ca.name,	ca.category_id
			FROM category ca
			WHERE name in ('Animation','Children','Classics','Comedy','Family','Music')

	)
SELECT
	f.title,
	ca.name,
	SUM(DATE_PART('day', r.return_date::timestamp -
		r.rental_date::timestamp)) AS rental_duration_date_part,
	SUM(DATE_TRUNC('day', r.return_date) -
		DATE_TRUNC('day', r.rental_date)) AS rental_duration,
	NTILE(4) OVER (
		ORDER BY SUM(DATE_TRUNC('day', r.return_date) -
									DATE_TRUNC('day', r.rental_date))) AS quartile
	FROM ca
	JOIN film_category FC ON ca.category_id = fc.category_id
	JOIN film f ON fc.film_id = f.film_id
	JOIN inventory i ON f.film_id = i.film_id
	JOIN rental r ON i.inventory_id = r. inventory_id
	GROUP BY 1,2
	ORDER BY 3;


/*-- Query Question 3  ----*/

WITH
	ca AS (
		SELECT ca.name, ca.category_id
			FROM category ca
			WHERE name in ('Animation','Children','Classics','Comedy','Family','Music')
	),
	duration_table AS (
		SELECT f.title, ca.name,
			SUM(DATE_PART('day', r.return_date::timestamp -
				r.rental_date::timestamp)) AS rental_duration_date_part,
			NTILE(4) OVER (ORDER BY SUM(DATE_PART('day', r.return_date::timestamp -
				r.rental_date::timestamp))) AS standard_quartile
			FROM ca
			JOIN film_category fc ON ca.category_id = fc.category_id
			JOIN film f ON fc.film_id = f.film_id
			JOIN inventory i ON f.film_id = i.film_id
			JOIN rental r ON i.inventory_id = r. inventory_id
			GROUP BY 1,2
			ORDER BY 3
	)
SELECT duration_table.name AS category, duration_table.standard_quartile,
	COUNT(duration_table.name) AS count_quartile
	FROM duration_table
	GROUP BY 1, 2
	ORDER BY 1, 2

/*-------------- Set2 Question 1 -----------------------*/

SELECT staff_id,
		DATE_PART('month', r.rental_date) AS rental_month,
		DATE_PART('year', r.rental_date) AS rental_year,
		s.store_id,
		COUNT(*)
FROM rental r
JOIN store s
ON r.staff_id = s.manager_staff_id

GROUP BY 1,2,3,4
ORDER BY 1,2;

/*-------------- Set2 Question 2 -----------------------*/
/*--- Top Customer - Subquery-----------------------*/
SELECT p.customer_id,
		SUM(p.amount) AS pay_amount
	FROM payment p
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT

/*--- Top All 'WITH' temporary table-----------------------*/
WITH
	top AS (
		SELECT customer_id,
				SUM(amount) AS amt
		FROM payment
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 10
		)
SELECT DATE_TRUNC('month', p.payment_date) AS pay_moth,
		CONCAT(cu.first_name,' ',cu.last_name) AS full_name,
		COUNT(p.payment_id) AS pay_countpermoth,
		SUM(p.amount) AS pay_amount

	FROM  customer cu
	JOIN top
	ON cu.customer_id = top.customer_id
	JOIN payment p
	ON top.customer_id = p.customer_id
	GROUP BY 1, 2
	ORDER BY 2,4 DESC;

/*	--- Top All with Subquery-----------------------*/

SELECT DATE_TRUNC('month', p.payment_date) AS pay_moth,
		CONCAT(cu.first_name,' ',cu.last_name) AS full_name,
		COUNT(p.payment_id) AS pay_countpermoth,
		SUM(p.amount) AS pay_amount

	FROM (
		SELECT customer_id,
				SUM(amount) AS amt
		FROM payment
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 10
	) AS top
	JOIN customer cu
	ON cu.customer_id = top.customer_id
	JOIN payment p
	ON top.customer_id = p.customer_id
	GROUP BY 1, 2
	ORDER BY 2,4 DESC;

/*---------------- Question Set 2 Question 3 --------------------*/

WITH
	top2 AS (

		SELECT DATE_TRUNC('month', p.payment_date) AS pay_month,
				CONCAT(cu.first_name,' ',cu.last_name) AS full_name,
				COUNT(p.payment_id) AS pay_countpermoth,
				SUM(p.amount) AS pay_amount,
				LEAD(SUM(p.amount)) OVER (PARTITION BY CONCAT(cu.first_name,' ',cu.last_name)
											ORDER BY DATE_TRUNC('month', p.payment_date)) AS lead,
				LEAD(SUM(p.amount)) OVER (PARTITION BY CONCAT(cu.first_name,' ',cu.last_name)
											ORDER BY DATE_TRUNC('month', p.payment_date)) - SUM(p.amount) AS lead_diff


			FROM (
				SELECT customer_id,
						SUM(amount) AS amt
				FROM payment
				GROUP BY 1
				ORDER BY 2 DESC
				LIMIT 10
			) AS top
			JOIN customer cu
			ON cu.customer_id = top.customer_id
			JOIN payment p
			ON top.customer_id = p.customer_id
			GROUP BY 1, 2
			ORDER BY 2, 1
	),
	max_value AS (
		SELECT MAX(lead_diff) AS pay_diff
			FROM top2

	)
SELECT top2.full_name, top2.pay_month, top2.lead_diff
	FROM top2
	WHERE top2.lead_diff = (SELECT pay_diff FROM max_value);
