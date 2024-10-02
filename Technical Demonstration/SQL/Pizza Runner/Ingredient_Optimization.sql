#Standard ingredients for each pizza
SELECT pn.PIZZA_NAME, pt.TOPPING_NAME
FROM PIZZA_RECIPES_CLEAN pc
JOIN PIZZA_NAMES pn ON pc.PIZZA_ID = pn.PIZZA_ID
JOIN PIZZA_TOPPINGS pt ON pc.TOPPINGS = pt.TOPPING_ID
ORDER BY pn.PIZZA_NAME, pt.TOPPING_NAME;


#Commonly added extra in pizza
WITH cte AS (
	SELECT pizza_id,
	       CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(EXTRAS, ',', n), ',', -1) AS UNSIGNED) AS extras
	FROM CUSTOMER_ORDERS
	JOIN (
	    SELECT 1 AS n UNION ALL
	    SELECT 2 
	) numbers
	ON CHAR_LENGTH(EXTRAS) - CHAR_LENGTH(REPLACE(EXTRAS, ',', '')) >= n - 1
)
SELECT topping_name, count_extras
FROM (SELECT extras, count_extras, row_number() OVER (ORDER BY count_extras DESC) rn, pt.topping_name
	FROM (SELECT extras, count(extras) count_extras
		FROM cte c
		GROUP BY extras) a
	JOIN PIZZA_TOPPINGS pt ON a.extras = pt.topping_id) b 
WHERE rn = 1;


#Common exclusion
WITH cte AS (
	SELECT pizza_id,
	       CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1) AS UNSIGNED) AS exclusions
	FROM CUSTOMER_ORDERS
	JOIN (
	    SELECT 1 AS n UNION ALL
	    SELECT 2 
	) numbers
	ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1
)
SELECT topping_name, count_exclusions
FROM (SELECT exclusions, count_exclusions, row_number() OVER (ORDER BY count_exclusions DESC) rn, pt.topping_name
	FROM (SELECT exclusions, count(exclusions) count_exclusions
		FROM cte c
		GROUP BY exclusions) a
	JOIN PIZZA_TOPPINGS pt ON a.exclusions = pt.topping_id) b 
WHERE rn = 1;


#Alphabetically ordered comma separated ingredient list for each pizza order
WITH cte AS (
	SELECT pizza_id,
	       CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS UNSIGNED) AS extras
	FROM CUSTOMER_ORDERS
	JOIN (
	    SELECT 1 AS n UNION ALL
	    SELECT 2 
	) numbers
	ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
)
SELECT pizza_name, GROUP_CONCAT(concat(tot_occurances,'x',topping_name) ORDER BY topping_name SEPARATOR ', ') AS format
FROM (SELECT pn.pizza_name, pt.topping_name, count(*) tot_occurances
	FROM cte c
	JOIN PIZZA_NAMES pn ON c.pizza_id = pn.pizza_id
	JOIN PIZZA_TOPPINGS pt ON c.extras = pt.topping_id
	GROUP BY pn.pizza_name, pt.topping_name
	ORDER BY pn.pizza_name) a
GROUP BY pizza_name;


#Total quantity of each ingredient used in all delivered pizzas sorted by most frequent first
WITH cte AS (
	SELECT pizza_id, order_time, 
	       CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS UNSIGNED) AS extras
	FROM CUSTOMER_ORDERS
	JOIN (
	    SELECT 1 AS n UNION ALL
	    SELECT 2 
	) numbers
	ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
)
SELECT a.ingredient, a.ingredient_used_count, b.order_time
FROM (SELECT pt.topping_name ingredient, count(*) ingredient_used_count
	FROM cte c
	JOIN PIZZA_TOPPINGS pt ON c.extras = pt.topping_id
	GROUP BY pt.topping_name) a 
JOIN (SELECT ingredient, order_time
	FROM (SELECT pt.topping_name ingredient, order_time, 
		row_number() OVER (PARTITION BY pt.topping_name ORDER BY order_time DESC) rn
		FROM cte c
		JOIN PIZZA_TOPPINGS pt ON c.extras = pt.topping_id) a 
	WHERE rn = 1) b ON a.ingredient = b.ingredient
ORDER BY b.order_time DESC;