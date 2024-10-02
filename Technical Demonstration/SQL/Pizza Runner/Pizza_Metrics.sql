#Total pizzas ordered
SELECT count(ro.ORDER_ID) number_of_orders
FROM runner_orders ro;


#Number of unique Customer Orders made
SELECT count(DISTINCT CONCAT(CUSTOMER_ID,'-',PIZZA_ID)) unique_customer_orders
FROM CUSTOMER_ORDERS;


#Successful orders delivered by each Runner
SELECT RUNNER_ID, count(ORDER_ID) orders_delivered
FROM RUNNER_ORDERS
WHERE DISTANCE_IN_KM IS NOT NULL 
GROUP BY RUNNER_ID;


#Number of unique pizzas delivered
SELECT pn.PIZZA_NAME, count(*) num_of_pizzaz_delivered
FROM RUNNER_ORDERS ro
JOIN CUSTOMER_ORDERS co ON ro.ORDER_ID = co.ORDER_ID
JOIN PIZZA_NAMES pn ON co.PIZZA_ID = pn.PIZZA_ID
WHERE 1 = 1
AND ro.DISTANCE_IN_KM IS NOT NULL 
GROUP BY pn.PIZZA_NAME; 


#Number of vegetarian and Meatlovers ordered by each customer
SELECT co.CUSTOMER_ID, pn.PIZZA_NAME, count(*) num_of_pizzas_ordered
FROM CUSTOMER_ORDERS co
JOIN PIZZA_NAMES pn ON co.PIZZA_ID = pn.PIZZA_ID
GROUP BY co.CUSTOMER_ID, pn.PIZZA_NAME
ORDER BY co.CUSTOMER_ID, pn.PIZZA_NAME; 


#Maximum number of pizzas delivered in a single order
WITH cte AS (
SELECT ORDER_ID, count(PIZZA_ID) tot_pizzas
FROM CUSTOMER_ORDERS 
GROUP BY order_id
)
SELECT order_id, tot_pizzas 
FROM (SELECT order_id, tot_pizzas, rank() OVER (ORDER BY tot_pizzas desc) rn
	FROM cte) a
WHERE rn = 1;


#Pizzas delivered for each customer having atleast 1 change or no change
SELECT CUSTOMER_ID, 
sum(CASE WHEN EXCLUSIONS IS NULL AND EXTRAS IS NULL THEN 1 ELSE 0 END) pizza_no_change, 
sum(CASE WHEN EXCLUSIONS IS NOT NULL OR EXTRAS IS NOT NULL THEN 1 ELSE 0 END) pizza_change
FROM CUSTOMER_ORDERS
GROUP BY CUSTOMER_ID;


#Total pizzas delivered having both exclusions and extras
SELECT count(*) tot_pizzas
FROM RUNNER_ORDERS ro
JOIN CUSTOMER_ORDERS co ON ro.ORDER_ID = co.ORDER_ID
WHERE 1 = 1
AND ro.DISTANCE_IN_KM IS NOT NULL 
AND (co.EXCLUSIONS IS NOT NULL AND co.EXTRAS IS NOT NULL);


#Total volume of pizzas ordered for each hour of the day
SELECT hour(ORDER_TIME) hour_of_day, count(*) tot_pizzas_ordered
FROM CUSTOMER_ORDERS
GROUP BY hour(ORDER_TIME);


#Total volume of orders for each day of the week
SELECT WEEKDAY(ORDER_TIME) week_of_day, count(*) tot_pizzas
FROM CUSTOMER_ORDERS
GROUP BY WEEKDAY(ORDER_TIME);