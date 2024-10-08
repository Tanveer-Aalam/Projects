#Creating new table where it calculates when the current plan ends for each customer
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



#Tenure of customer and determining if customer is churned or existing
SELECT s.CUSTOMER_ID, min(s.START_DATE) cust_join_date, max(se.PLAN_END_DATE) cust_last_date, count(s.plan_id) tot_plans, 
DATEDIFF(max(se.plan_end_date), min(s.start_date)) cust_tenure_days, 
CASE 
	WHEN ch.CUSTOMER_ID IS NOT NULL THEN 'Existing Customer'
	WHEN ch.CUSTOMER_ID IS NULL THEN 'Churned Customer'
END churn_cust_status
FROM SUBSCRIPTIONS s
JOIN PLANS p ON s.PLAN_ID = p.PLAN_ID
LEFT JOIN SUBSCRIPTION_ENDS se ON s.CUSTOMER_ID = se.CUSTOMER_ID AND s.PLAN_ID = se.PLAN_ID
LEFT JOIN PLANS pe ON se.PLAN_ID = pe.PLAN_ID
LEFT JOIN (SELECT DISTINCT s.CUSTOMER_ID
		FROM SUBSCRIPTIONS s
		WHERE s.PLAN_ID = 4) ch ON s.CUSTOMER_ID = ch.customer_id
GROUP BY s.CUSTOMER_ID, churn_cust_status
ORDER BY s.CUSTOMER_ID;



#Customer churn rate - Month on Month
WITH cte AS (
	SELECT s.CUSTOMER_ID, min(s.START_DATE) cust_join_date
	FROM SUBSCRIPTIONS s
	GROUP BY s.CUSTOMER_ID
)
SELECT join_month_year, tot_custs - previous_month_custs customer_churn_count, 
round(((tot_custs - previous_month_custs)/tot_custs)*100,2) customer_churn_percentage
FROM (SELECT month_year_seq, join_month_year, tot_custs, 
	lag(tot_custs) OVER (ORDER BY month_year_seq) previous_month_custs
	FROM (SELECT month_year_seq, join_month_year, count(customer_id) tot_custs
		FROM (SELECT customer_id, cust_join_date, DATE_FORMAT(cust_join_date, '%M %Y') join_month_year, 
			CASE 
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'January 2020' THEN 1
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'February 2020' THEN 2
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'March 2020' THEN 3
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'April 2020' THEN 4
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'May 2020' THEN 5
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'June 2020' THEN 6
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'July 2020' THEN 7
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'August 2020' THEN 8
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'September 2020' THEN 9
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'October 2020' THEN 10
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'November 2020' THEN 11
				WHEN DATE_FORMAT(cust_join_date, '%M %Y') = 'December 2020' THEN 12
			END month_year_seq
			FROM cte) a
		GROUP BY join_month_year, month_year_seq) b
	ORDER BY month_year_seq) c
ORDER BY month_year_seq;