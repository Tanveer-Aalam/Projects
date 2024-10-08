CREATE TABLE subscription_ends AS 
SELECT s.CUSTOMER_ID, s.PLAN_ID, 
CASE 
	WHEN p.PLAN_NAME = 'trial' THEN date_add(s.START_DATE, INTERVAL 6 day)
	WHEN p.plan_name = 'basic monthly' THEN date_add(s.START_DATE, INTERVAL 1 month) - INTERVAL 1 day
	WHEN p.plan_name = 'pro annual' THEN date_add(s.START_DATE, INTERVAL 1 year) - INTERVAL 1 day
	WHEN p.plan_name = 'pro monthly' THEN date_add(s.START_DATE, INTERVAL 1 month) - INTERVAL 1 day
	WHEN p.plan_name = 'churn' THEN NULL
END plan_end_date
FROM SUBSCRIPTIONS s
JOIN plans p ON s.PLAN_ID = p.PLAN_ID
WHERE p.PLAN_NAME NOT IN ('churn')