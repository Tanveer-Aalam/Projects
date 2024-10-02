#Number of runners signed up on each week starting from 2021-01-01
WITH dates AS (
    SELECT '2021-01-01' AS date_val
    UNION ALL
    SELECT DATE_ADD(registration_date, INTERVAL 1 DAY) 
    FROM RUNNERS 
    WHERE registration_date < (SELECT max(registration_date) FROM RUNNERS)
)
SELECT week_label, count(RUNNER_ID)
FROM (SELECT REGISTRATION_DATE, RUNNER_ID, 
    CONCAT('Week', FLOOR(DATEDIFF(REGISTRATION_DATE, '2021-01-01') / 7) + 1) AS week_label
	FROM RUNNERS) a
GROUP BY week_label;


#Averge distance travelled for each customer
SELECT co.CUSTOMER_ID, round(avg(ro.distance_in_km),2) avg_distance
FROM CUSTOMER_ORDERS co
JOIN RUNNER_ORDERS ro ON co.ORDER_ID = ro.ORDER_ID
WHERE ro.DISTANCE_IN_KM IS NOT NULL 
GROUP BY co.CUSTOMER_ID;


#Difference between the longest and shortest delivery times for all orders
SELECT max(DURATION_IN_MINS) - min(DURATION_IN_MINS) delivery_time_difference
FROM RUNNER_ORDERS;


#Average speed of each runner
WITH cte AS (
	SELECT order_id, runner_id, pickup_time, distance_in_km, duration_in_mins, 
	round((DISTANCE_IN_KM/DURATION_IN_MINS)*60,2) runner_speed
	FROM RUNNER_ORDERS
	WHERE DISTANCE_IN_KM IS NOT NULL 
)
SELECT runner_id, count(order_id), round(sum(distance_in_km),2) tot_distance_travelled, 
sum(duration_in_mins) tot_duration, round(avg(runner_speed),2) avg_runner_speed_km_h
FROM cte 
GROUP BY runner_id; 


#Successful delivery percentage by each runner
WITH cte AS (
	SELECT r1.runner_id, count(r1.order_id) tot_orders, r2.success_order
	FROM RUNNER_ORDERS r1
	LEFT JOIN (SELECT RUNNER_ID, count(ORDER_ID) success_order
			FROM RUNNER_ORDERS
			WHERE DISTANCE_IN_KM IS NOT NULL 
			GROUP BY RUNNER_ID) r2 ON r1.RUNNER_ID = r2.runner_id
	GROUP BY r1.runner_id, r2.success_order
)
SELECT runner_id, (success_order/tot_orders)*100 success_percentage
FROM cte;