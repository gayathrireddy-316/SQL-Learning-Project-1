--Q1)What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) 
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id



--Q2)How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date))
FROM sales
GROUP BY customer_id



--Q3)What was the first item from the menu purchased by each customer?
WITH CTE AS (
  SELECT 
    s.customer_id,
    s.order_date,
    m.product_name, 
    RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY order_date) as rank,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) as rownum
  FROM sales s
  JOIN menu m 
  on s.product_id = m.product_id
) 
SELECT customer_id, product_name
FROM CTE 
WHERE rownum = 1



--Q4)What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
  m.product_name, 
  COUNT(s.order_date) as orders 
FROM sales as S
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY m.product_name 
ORDER BY COUNT(order_date) DESC 
LIMIT 1



--Q5)Which item was the most popular for each customer?
WITH CTE AS (
  SELECT m.product_name, s.customer_id, 
    COUNT(s.order_date) as orders,
 ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.order_date) DESC) as rn
	FROM sales s
   INNER JOIN menu m 
	ON s.product_id = m.product_id 
  GROUP BY m.product_name, s.customer_id
)
SELECT customer_id, product_name
FROM CTE
WHERE rn=1;


--Q6)Which item was purchased first by the customer after they became a member?
with first_purchased_item as (
	SELECT s.customer_id, s.order_date , me.join_date, m.product_name,
ROW_NUMBER() OVER(partition by s.customer_id order by order_date) as rn
FROM members me
JOIN sales s
ON me.customer_id = s.customer_id
JOIN menu m 
ON s.product_id = m.product_id
	where s.order_date>=me.join_date
	order by s.order_date
)
select customer_id, product_name
FROM first_purchased_item
where rn = 1


--Q7)Which item was purchased just before the customer became a member?
with first_purchased_item as 
(
	SELECT s.customer_id, s.order_date , me.join_date, m.product_name,
ROW_NUMBER() OVER(partition by s.customer_id order by s.order_date asc) as rn
FROM members me
JOIN sales s
ON me.customer_id = s.customer_id
JOIN menu m 
ON s.product_id = m.product_id
	where s.order_date < me.join_date
	order by s.order_date
)
SELECT customer_id, product_name
FROM first_purchased_item
WHERE rn = 1


--Q8)What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, count(s.product_id) as total_items , sum(m.price) as total_price
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members me
ON s.customer_id = me.customer_id
where s.order_date < me.join_date
GROUP BY s.customer_id



--Q9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier-how many points would each customer have?
SELECT s.customer_id,
SUM
( CASE
	when product_name = 'sushi' then price * 20
	ELSE price * 10
	END ) AS points 
	
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id


--Q10)In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select S.customer_id, 
  SUM(
  CASE 
      WHEN S.order_date BETWEEN MEM.join_date AND (join_date + interval '6 days')  THEN price * 10 * 2 
      ELSE price * 10 
    END
   )as points 
FROM 
  MENU as M 
  INNER JOIN SALES as S ON S.product_id = M.product_id
  INNER JOIN MEMBERS AS MEM ON MEM.customer_id = S.customer_id 
WHERE 
  extract(month from order_date) = 1 
GROUP BY 
  S.customer_id;




