#Total amount each customer spent at the restaurant
SELECT DISTINCT s.CUSTOMER_ID, sum(mn.PRICE) total_amount
FROM sales s
LEFT JOIN members m ON m.CUSTOMER_ID = s.CUSTOMER_ID
LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
GROUP BY s.CUSTOMER_ID;


#Number of days each customer has visited the restaurant
SELECT s.CUSTOMER_ID, count(DISTINCT s.ORDER_DATE) num_days
FROM sales s
GROUP BY s.CUSTOMER_ID;


#First item from the menu purchased by each customer
SELECT customer_id, order_date, product_name, product_id 
FROM (SELECT s.CUSTOMER_ID, s.ORDER_DATE, m.PRODUCT_NAME, s.product_id, 
	row_number() OVER (PARTITION BY s.CUSTOMER_ID ORDER BY s.ORDER_DATE) rn
	FROM sales s
	JOIN menu m ON s.PRODUCT_ID = m.PRODUCT_ID) a
WHERE rn = 1;


#Most purchased item on the menu and number of times it purchased by all customers
SELECT m.PRODUCT_NAME, count(s.PRODUCT_ID) num_of_times_purchased
FROM sales s
LEFT JOIN menu m ON s.PRODUCT_ID = m.PRODUCT_ID
GROUP BY m.PRODUCT_NAME;


#Most popular item for each customer
SELECT customer_id, product_name, num_of_times_ordered
FROM (SELECT customer_id, product_name, num_of_times_ordered, 
	row_number() OVER (PARTITION BY customer_id ORDER BY num_of_times_ordered DESC) rn
	FROM (SELECT DISTINCT s.CUSTOMER_ID, mn.PRODUCT_NAME, count(s.PRODUCT_ID) num_of_times_ordered
		FROM sales s
		LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
		GROUP BY s.CUSTOMER_ID, mn.PRODUCT_NAME
		ORDER BY s.CUSTOMER_ID, mn.PRODUCT_NAME) a) b 
WHERE rn = 1;


#First item purchased by the customer after they became a member
SELECT customer_id, join_date, order_date, product_name
FROM (SELECT customer_id, join_date, order_date, product_name, 
	row_number() OVER (PARTITION BY customer_id ORDER BY order_date) rn 
	FROM (SELECT DISTINCT s.CUSTOMER_ID, m.JOIN_DATE, s.ORDER_DATE, mn.PRODUCT_NAME
		FROM sales s
		LEFT JOIN members m ON s.CUSTOMER_ID = m.CUSTOMER_ID
		LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
		WHERE 1 = 1
		AND s.ORDER_DATE >= m.JOIN_DATE) a) b 
WHERE rn = 1;


#Item purchased by customer just before they became a member
SELECT customer_id, join_date, order_date, product_name
FROM (SELECT customer_id, join_date, order_date, product_name, product_id, 
	row_number() OVER (PARTITION BY customer_id ORDER BY order_date DESC, product_id DESC) rn 
	FROM (SELECT DISTINCT s.CUSTOMER_ID, m.JOIN_DATE, s.ORDER_DATE, mn.PRODUCT_NAME, mn.product_id
		FROM sales s
		LEFT JOIN members m ON s.CUSTOMER_ID = m.CUSTOMER_ID
		LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
		WHERE 1 = 1
		AND s.ORDER_DATE < m.JOIN_DATE) a) b 
WHERE rn = 1;


#Total items and amount spent by each member before they became a member
SELECT DISTINCT s.CUSTOMER_ID, count(s.PRODUCT_ID) tot_products_purchased, sum(mn.PRICE) tot_amount_spent
FROM sales s
LEFT JOIN members m ON s.CUSTOMER_ID = m.CUSTOMER_ID
LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
WHERE 1 = 1
AND s.ORDER_DATE < m.JOIN_DATE
GROUP BY s.CUSTOMER_ID
ORDER BY s.CUSTOMER_ID;


#Points each customer would have if each $1 spent equates to 10 points and sushi has a 2x points multiplier
SELECT customer_id, sum(points) total_points
FROM (SELECT s.CUSTOMER_ID, s.ORDER_DATE, s.PRODUCT_ID, mn.PRODUCT_NAME, mn.PRICE, 
	CASE 
		WHEN mn.product_name = 'sushi' THEN mn.price * 20
		ELSE mn.price * 10
	END points
	FROM sales s
	LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID) a 
GROUP BY customer_id;


#Points customers have at the end of January after they join the program and in the first week of joining they earn 2x points on all items
SELECT s.CUSTOMER_ID, sum(mn.PRICE * 20) tot_points
FROM sales s
JOIN members m ON s.CUSTOMER_ID = m.CUSTOMER_ID
JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID
WHERE 1 = 1
AND DATEDIFF(s.ORDER_DATE, m.JOIN_DATE) BETWEEN 0 AND 6
AND s.ORDER_DATE <= '2021-01-31'
GROUP BY s.CUSTOMER_ID
ORDER BY s.CUSTOMER_ID;


#Ranking all the items after joining of customer
SELECT s.CUSTOMER_ID, s.ORDER_DATE, mn.PRODUCT_NAME, mn.PRICE, 
CASE 
	WHEN s.order_date >= m.JOIN_date THEN 'Y'
	ELSE 'N'
END is_member, 
CASE
	WHEN s.order_date >= m.join_date THEN RANK() OVER (PARTITION BY s.customer_id, 
                                            				CASE WHEN s.order_date >= m.join_date THEN 1 ELSE 0 END
                                   						ORDER BY s.ORDER_date)
	ELSE NULL 
END ranking
FROM sales s
LEFT JOIN members m ON s.CUSTOMER_ID = m.CUSTOMER_ID
LEFT JOIN menu mn ON s.PRODUCT_ID = mn.PRODUCT_ID;