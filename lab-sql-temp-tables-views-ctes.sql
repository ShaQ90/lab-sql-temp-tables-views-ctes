USE sakila;


-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW sakila.rental_information;

CREATE VIEW rental_information AS 
SELECT 
	c.customer_id as customer,
	CONCAT(c.first_name, " ", c.last_name) as name, 
    c.email as email, 
    count(r.rental_id) as rental_count FROM sakila.customer as c
JOIN sakila.rental as r
ON  c.customer_id= r.customer_id
GROUP BY c.customer_id;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
DROP VIEW calculate_total_paid;

CREATE TEMPORARY TABLE calculate_total_paid
SELECT re.customer as customer,
	SUM(p.amount) as total_paid
FROM sakila.rental_information as re
JOIN sakila.rental as r
ON re.customer = r.customer_id
JOIN sakila.payment as p
ON r.rental_id = p.rental_id
GROUP BY customer;

select * from calculate_total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
--  The CTE should include the customer's name, email address, rental count, and total amount paid.

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH cte_summary AS (
	SELECT re.name as name, re.email as email , re.rental_count, ca.total_paid , (ca.total_paid / re.rental_count) as average_payment_per_rental
	FROM sakila.rental_information as re
	JOIN sakila.calculate_total_paid as ca
	ON re.customer = ca.customer
)
SELECT * FROM cte_summary;