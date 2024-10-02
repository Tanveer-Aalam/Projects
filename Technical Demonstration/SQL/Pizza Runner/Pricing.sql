#Money made by runner if meat pizza costs $12 and vegetarian costs $10
WITH cte AS (
	SELECT runner_id, pizza_name, sum(price) tot_price
	FROM (SELECT ro.RUNNER_ID, pn.pizza_name, 
		CASE 
			WHEN pn.PIZZA_NAME = 'Meatlovers' THEN 12
			ELSE 10
		END price
		FROM CUSTOMER_ORDERS co
		JOIN RUNNER_ORDERS ro ON co.ORDER_ID = ro.ORDER_ID
		JOIN PIZZA_NAMES pn ON co.PIZZA_ID = pn.PIZZA_ID 
		WHERE ro.DISTANCE_IN_KM IS NOT NULL) a
	GROUP BY ro.RUNNER_ID, pn.pizza_name
)
SELECT runner_id, sum(tot_price) money_earned
FROM cte 
GROUP BY runner_id;


#Money made by runner if meat pizza costs $12 and vegetarian costs $10 and additional $1 for an extra
WITH cte AS (
	SELECT runner_id, pizza_name, sum(price) tot_price, count(num_extras) tot_extras
	FROM (SELECT ro.RUNNER_ID, pn.pizza_name, CHAR_LENGTH(co.extras) - CHAR_LENGTH(REPLACE(co.extras, ',', '')) + 1 num_extras, 
		CASE 
			WHEN pn.PIZZA_NAME = 'Meatlovers' THEN 12
			ELSE 10
		END price
		FROM CUSTOMER_ORDERS co
		JOIN RUNNER_ORDERS ro ON co.ORDER_ID = ro.ORDER_ID
		JOIN PIZZA_NAMES pn ON co.PIZZA_ID = pn.PIZZA_ID 
		WHERE ro.DISTANCE_IN_KM IS NOT NULL) a
	GROUP BY ro.RUNNER_ID, pn.pizza_name
)
SELECT runner_id, sum(tot_price + tot_extras) money_earned
FROM cte 
GROUP BY runner_id;


#Money made by runner if meat pizza costs $12 and vegetarian costs $10 and $0.30 per km travelled
WITH cte AS (
	SELECT runner_id, pizza_name, sum(price) tot_price, distance_in_km
	FROM (SELECT ro.RUNNER_ID, pn.pizza_name, ro.distance_in_km, 
		CASE 
			WHEN pn.PIZZA_NAME = 'Meatlovers' THEN 12
			ELSE 10
		END price
		FROM CUSTOMER_ORDERS co
		JOIN RUNNER_ORDERS ro ON co.ORDER_ID = ro.ORDER_ID
		JOIN PIZZA_NAMES pn ON co.PIZZA_ID = pn.PIZZA_ID 
		WHERE ro.DISTANCE_IN_KM IS NOT NULL) a
	GROUP BY ro.RUNNER_ID, pn.pizza_name, distance_in_km
)
SELECT runner_id, sum(tot_price + travel_amount) tot_money_earned
FROM (SELECT runner_id, tot_price, round(distance_in_km * 0.30,2) travel_amount
	FROM cte) a 
GROUP BY runner_id;