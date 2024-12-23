/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
          S.customer_id, 
          SUM(M.price) AS Totalamount
FROM
dannys_diner.sales S
JOIN 
dannys_diner.menu M
ON 
S.product_id = M.product_id
GROUP BY 1 
ORDER BY Totalamount DESC;

-- 2. How many days has each customer visited the restaurant?

With customers_visit AS (	SELECT
    S.customer_id,
    COUNT  (DISTINCT S.order_date) AS Days
FROM
    dannys_diner.sales S
GROUP BY 1)

SELECT *
FROM 
customers_visit
ORDER BY Days DESC;



-- 3. What was the first item from the menu purchased by each customer?


SELECT 
    S.customer_id, 
    M.product_name, 
    MIN(S.order_date) AS first_purchase_date
FROM 
    dannys_diner.sales S
JOIN 
    dannys_diner.menu M
ON 
    S.product_id = M.product_id
GROUP BY 
    S.customer_id, M.product_name,S.order_date
HAVING 
    S.order_date = (
        SELECT MIN(S2.order_date)
        FROM dannys_diner.sales S2
        WHERE S2.customer_id = S.customer_id
    )
ORDER BY 
    S.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
     M.product_name, 
     COUNT(S.product_id) no_of_times
FROM dannys_diner.sales S
JOIN dannys_diner.menu M
ON S.product_id = M.product_id
GROUP BY 1
ORDER BY 2 DESC
lIMIT 1; 

-- 5. Which item was the most popular for each customer?
WITH most_popular AS (SELECT 
     S.customer_id,
     M.product_name,
     COUNT(S.product_id) no_of_items, 
     DENSE_RANK() OVER(PARTITION BY S.customer_id ORDER BY COUNT(S.product_id) DESC ) rn 
FROM dannys_diner.sales S
JOIN dannys_diner.menu M 
ON S.product_id = M.product_id
GROUP BY 1, 2, S.product_id
)
SELECT
    customer_id,
    product_name,
    no_of_items, rn
FROM most_popular
WHERE rn = 1
ORDER BY 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS (SELECT 
    S.customer_id,
    M.product_name, S.order_date,
    ME.join_date,
    ROW_NUMBER() OVER (
            PARTITION BY S.customer_id
            ORDER BY S.order_date ASC
        ) AS rn         
FROM dannys_diner.sales S 
JOIN dannys_diner.menu M
ON S.product_id = M.product_id
JOIN dannys_diner.members ME
ON S.customer_id = ME.customer_id
WHERE order_date >= join_date             
)
SELECT *
FROM CTE
WHERE rn = 1;
    
-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (SELECT 
    S.customer_id,
    M.product_name, S.order_date,
    ME.join_date,
    ROW_NUMBER() OVER (
            PARTITION BY S.customer_id
            ORDER BY S.order_date DESC
        ) AS rn         
FROM dannys_diner.sales S 
JOIN dannys_diner.menu M
ON S.product_id = M.product_id
JOIN dannys_diner.members ME
ON S.customer_id = ME.customer_id
WHERE order_date < join_date             
)
SELECT 
	customer_id,
    product_name
FROM CTE
WHERE rn = 1;
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	S.customer_id,
    COUNT(S.product_id) total_item,
    SUM(M.price) total_amount$
FROM dannys_diner.sales S 
JOIN dannys_diner.menu M
ON S.product_id = M.product_id
JOIN dannys_diner.members ME
ON S.customer_id = ME.customer_id
WHERE S.order_date < ME.join_date
GROUP BY 1
ORDER BY 3 DESC;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	S.customer_id,
    SUM(
      	CASE
      		WHEN M.product_name = 'SUSHI' THEN price * 20
      		ELSE M.price * 10
      END
    ) AS total_points
FROM dannys_diner.sales S
JOIN dannys_diner.menu M
ON S.product_id = M.product_id
GROUP BY 1
ORDER BY 2 DESC;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
