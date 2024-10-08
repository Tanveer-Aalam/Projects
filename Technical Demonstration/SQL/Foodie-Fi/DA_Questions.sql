#Number of customers foodie-fi had
SELECT count(DISTINCT s.CUSTOMER_ID) num_custs
FROM SUBSCRIPTIONS s
WHERE s.PLAN_ID <> 4;


#Monthly distribution of trial plan start_date values
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	DATE_SUB(s.START_DATE, INTERVAL DAY(s.START_DATE) - 1 DAY) first_day_of_trail_period
	FROM SUBSCRIPTIONS s
	JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
	WHERE 1 = 1
	AND p.PLAN_NAME = 'trial'
)
SELECT first_day_of_trail_period, plan_name, count(*) monthly_distribution
FROM cte 
GROUP BY first_day_of_trail_period, plan_name
ORDER BY first_day_of_trail_period;


#Customer count & Percentage of customers who have churned
SELECT count(DISTINCT s.customer_id) tot_custs, 
round(((SELECT count(DISTINCT customer_id) FROM SUBSCRIPTIONS WHERE plan_id = 4)/count(DISTINCT s.CUSTOMER_ID))*100,1) churn_cust_percentage
FROM SUBSCRIPTIONS s;


#Customers who have churned straight after their initial free trial and their percentage
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	lead(p.PLAN_NAME) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) next_plan
	FROM SUBSCRIPTIONS s
	LEFT JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
)
SELECT (SELECT count(DISTINCT customer_id) FROM SUBSCRIPTIONS) tot_custs, count(DISTINCT c.customer_id) churn_custs, 
round((count(DISTINCT c.customer_id)/(SELECT count(DISTINCT customer_id) FROM SUBSCRIPTIONS))*100,1) trial_churn_custs_percentage
FROM cte c
WHERE plan_name = 'trial' 
AND next_plan = 'churn';


#Number and percentage of customer plans after their initial free trial
WITH cte AS (
	SELECT DISTINCT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	lead(p.PLAN_NAME, 1) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) first_plan_after_trail, 
	lead(p.PLAN_NAME, 2) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) second_plan_after_trail, 
	lead(p.PLAN_NAME, 3) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) third_plan_after_trail
	FROM SUBSCRIPTIONS s
	LEFT JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
)
SELECT DISTINCT trail_next_plans, count(DISTINCT customer_id) tot_custs, 
round((count(DISTINCT customer_id)/(SELECT count(DISTINCT customer_id) FROM SUBSCRIPTIONS))*100,1) custs_percentage
FROM (SELECT customer_id, trail_next_plans
	FROM (SELECT customer_id, plan_name, concat(plan_name,'-',first_plan_after_trail) trail_next_plans
		FROM cte
		WHERE plan_name = 'trial'
		UNION ALL
		SELECT customer_id, plan_name, concat(plan_name,'-',second_plan_after_trail) trail_next_plans
		FROM cte
		WHERE plan_name = 'trial'
		UNION ALL
		SELECT customer_id, plan_name, concat(plan_name,'-',third_plan_after_trail) trail_next_plans
		FROM cte
		WHERE plan_name = 'trial') a
	WHERE trail_next_plans IS NOT NULL) b
GROUP BY trail_next_plans;


#Customer count and percentage breakdown of all 5 plan_name values at 2020-12-31
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.PLAN_ID, s.START_DATE, p.PLAN_NAME, p.PRICE, 
	CASE 
		WHEN p.PLAN_NAME = 'trial' THEN date_add(s.START_DATE, INTERVAL 6 day)
		WHEN p.plan_name = 'basic monthly' THEN date_add(s.START_DATE, INTERVAL 1 month) - INTERVAL 1 day
		WHEN p.plan_name = 'pro annual' THEN date_add(s.START_DATE, INTERVAL 1 year) - INTERVAL 1 day
		WHEN p.plan_name = 'pro monthly' THEN date_add(s.START_DATE, INTERVAL 1 month) - INTERVAL 1 day
		WHEN p.plan_name = 'churn' THEN NULL
	END plan_end_date
	FROM SUBSCRIPTIONS s
	JOIN plans p ON s.PLAN_ID = p.PLAN_ID
)
SELECT plan_name, count(DISTINCT customer_id) plan_wise_custs, 
round((count(DISTINCT customer_id)/(SELECT count(DISTINCT customer_id) FROM SUBSCRIPTIONS))*100,1) plan_wise_cust_percentage
FROM cte
WHERE '2020-12-31' BETWEEN start_date AND plan_end_date
OR plan_name = 'churn'
GROUP BY plan_name;


#Number of Customers upgraded to annual plan in 2020
SELECT count(DISTINCT s.CUSTOMER_ID) tot_custs
FROM SUBSCRIPTIONS s
JOIN plans p ON s.PLAN_ID = p.PLAN_ID
WHERE 1 = 1
AND p.PLAN_NAME = 'pro annual'
AND date(s.START_DATE) BETWEEN '2020-01-01' AND '2020-12-31';


#Number of days on average it took for a customer to join an annual plan from the day they join
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	lead(s.START_DATE) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) pro_annual_date
	FROM SUBSCRIPTIONS s
	JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
	WHERE p.PLAN_NAME IN ('trial', 'pro annual')
)
SELECT customer_id, start_date, pro_annual_date, DATEDIFF(pro_annual_date, start_date) annual_subscibing_diff_days 
FROM cte
WHERE pro_annual_date IS NOT NULL; 


#Breaking-down the above value into 30 day periods
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	lead(s.START_DATE) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) pro_annual_date
	FROM SUBSCRIPTIONS s
	JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
	WHERE p.PLAN_NAME IN ('trial', 'pro annual')
)
SELECT customer_id, annual_subscibing_diff_days, 
CASE 
	WHEN annual_subscibing_diff_days BETWEEN 0 AND 30 THEN '0-30'
	WHEN annual_subscibing_diff_days BETWEEN 31 AND 60 THEN '31-60'
	WHEN annual_subscibing_diff_days BETWEEN 61 AND 90 THEN '61-90'
	WHEN annual_subscibing_diff_days BETWEEN 91 AND 120 THEN '91-120'
	WHEN annual_subscibing_diff_days BETWEEN 121 AND 150 THEN '121-150'
	WHEN annual_subscibing_diff_days BETWEEN 151 AND 180 THEN '151-180'
	WHEN annual_subscibing_diff_days BETWEEN 181 AND 270 THEN '181-270'
	WHEN annual_subscibing_diff_days > 271 THEN '>271'
END breakdown_period
FROM (SELECT customer_id, start_date, pro_annual_date, DATEDIFF(pro_annual_date, start_date) annual_subscibing_diff_days 
	FROM cte
	WHERE pro_annual_date IS NOT NULL) a;
	

#Number of customers downgraded from pro monthly plan to basic monthly plan in the year 2020
WITH cte AS (
	SELECT s.CUSTOMER_ID, s.START_DATE, p.PLAN_NAME, 
	lead(p.PLAN_NAME) OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.START_DATE) next_plan
	FROM SUBSCRIPTIONS s
	LEFT JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
	WHERE p.PLAN_NAME IN ('pro monthly', 'basic monthly')
	ORDER BY s.CUSTOMER_ID, s.START_DATE
)
SELECT *
FROM cte
WHERE plan_name = 'pro monthly'
AND next_plan = 'basic monthly'
AND start_date BETWEEN '2020-01-01' AND '2020-12-31';