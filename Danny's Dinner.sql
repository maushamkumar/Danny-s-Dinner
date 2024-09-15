-- I created the tables on My sql server. 

CREATE TABLE sales (
      customer_id VARCHAR(1),
      order_date DATE,
      product_id INTEGER
    );
    
 INSERT INTO sales
      (customer_id, order_date, product_id)
    VALUES
      ('A', '2024-01-01', '1'),
      ('A', '2024-01-01', '2'),
      ('A', '2024-01-07', '2'),
      ('A', '2024-01-10', '3'),
      ('A', '2024-01-11', '3'),
      ('A', '2024-01-11', '3'),
      ('B', '2024-01-01', '2'),
      ('B', '2024-01-02', '2'),
      ('B', '2024-01-04', '1'),
      ('B', '2024-01-11', '1'),
      ('B', '2024-01-16', '3'),
      ('B', '2024-02-01', '3'),
      ('C', '2024-01-01', '3'),
      ('C', '2024-01-01', '3'),
      ('C', '2024-01-07', '3');
 

CREATE TABLE menu (
      product_id INTEGER,
      product_name VARCHAR(5),
      price INTEGER
    );
    
INSERT INTO menu
      (product_id, product_name, price)
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');    
      

CREATE TABLE members (
      customer_id VARCHAR(1),
      join_date DATE
    );

    INSERT INTO members
      (customer_id, join_date)
    VALUES
      ('A', '2024-01-07'),
      ('B', '2024-01-09');
	truncate members;

  
-- Question 1:
-- What is the Total Amount each customer spent at the restaurant
-- First, I inner joined tables 'Sales' and 'Menu'
select s.customer_id, m.price
 from menu m
 inner join sales s 
 on m.product_id = s.product_id ;
 
 -- Then, I used SUM function with group by:
 select s.customer_id, sum(m.price) as TotalPrice
 from menu m
 inner join sales s 
 on m.product_id = s.product_id 
 group by s.customer_id 
 order by TotalPrice desc;
 
 
 -- Question 2: 
 -- How many days has each customer visited the restaurant?\
 -- I used the function COUNT and GROUP BY with Order by 
 select s.customer_id, count(m.price) as VisitDays
 from menu m
 inner join sales s 
 on m.product_id = s.product_id 
 group by s.customer_id 
 order by VisitDays desc;
 
 -- Question 3:
 -- what was the first item from the menu purchased by each customer?
 select s.order_date, s.customer_id, m.product_name
 from menu m
 inner join sales s 
 on m.product_id = s.product_id
 order by s.order_date 
 limit 1, 3;
 
 -- Another way 
 -- First, I joined tables sales and menu;
 select customer_id, product_name, order_date
 from sales
 inner join menu 
 on sales.product_id = menu.product_id;
 
 -- Then, I organized by order date and customer_id:
select customer_id, product_name, order_date
 from sales
 inner join menu 
 on sales.product_id = menu.product_id
 order by order_date;
 
 -- After finding out the first date, I added a WHERE clause to make the results clearer:
 select customer_id, product_name, order_date
 from sales
 inner join menu 
 on sales.product_id = menu.product_id
 where order_date = '2024-01-01'
 order by order_date
 ;

-- Question 4:
-- What is the most purchased item on the menu and how many times it was purchased by all customers?

-- I used the joined tables 'sales' and 'menu'
select customer_id, product_name
from sales
inner join menu
on sales.product_id = menu.product_id;

-- Then, I used the COUNT function, COUNT function, combined with GROUP BY and ORDER BY
select product_name, count(product_name) as times_purchased
from sales
inner join menu
on sales.product_id = menu.product_id
group by product_name
order by Times_purchased desc;

-- Question 5:
-- Which item was the most poppular for each customer?

-- Using RANK and PARTITION BY function
WITH r AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS order_count,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id)) AS customer_rank
    FROM
        sales s
        INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id,
        m.product_name
)

SELECT
    customer_id,
    product_name,
    order_count
FROM
    r
WHERE
    customer_rank = 1;
--


SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS item_bought_count,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS customer_rank
    FROM
        sales s
        INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id,
        m.product_name;  
        
  --  
  
  
WITH r AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS item_bought_count,
        DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS customer_rank
    FROM
        sales s
        INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY
        s.customer_id,
        m.product_name
)

SELECT
    customer_id,
    product_name,
    item_bought_count
FROM
    r
WHERE
    customer_rank = 1;


-- Question 6
-- which item was purchased first by the customer after they became a member?

-- First, I joined the three tables, since the common key was customer_id on both members and sales table.

-- The product information was on the menu table.
select s.customer_id, s.order_date, m.product_name, m1.join_date
from sales s
join menu m 
on s.product_id = m.product_id
	join members m1
    on m1.customer_id = s.customer_id;
    
-- Then, I used ROW_NUMBER in a CTE:

select row_number() over (partition by m1.customer_id order by m.product_name) as row_id, 
s.customer_id, s.order_date, m.product_name
from sales s
join menu m 
on s.product_id = m.product_id
join members m1
on m1.customer_id = s.customer_id
where s.order_date >= m1.join_date;

with cte as (
select row_number() over (partition by m1.customer_id order by m.product_name) as row_id, 
s.customer_id, s.order_date, m.product_name
from sales s
join menu m 
on s.product_id = m.product_id
join members m1
on m1.customer_id = s.customer_id
where s.order_date >= m1.join_date)

select *
 from cte
 where row_id = 1;
 
-- Question 7:
-- Which item has purchased just before the customer bexame a member

-- This result can be axxomplished by using CTE, modifying the partition by and switching the sign > to < when comparing the order date vs join date 
SELECT ROW_NUMBER () OVER (PARTITION BY m1.customer_id ORDER BY s.order_date) AS row_id, 
	s.customer_id, s.order_date, m.product_name 
	FROM sales s
    	JOIN menu m
    	ON s.product_id = m.product_id
    	JOIN members m1
    	ON m1.customer_id = s.customer_id
		WHERE s.order_date < m1.join_date;

WITH cte AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY m1.customer_id ORDER BY s.order_date) AS row_id,
        s.customer_id,
        s.order_date,
        m.product_name
    FROM
        sales s
        JOIN menu m ON s.product_id = m.product_id
        JOIN members m1 ON m1.customer_id = s.customer_id
)
SELECT
    c.customer_id,
    c.product_name
FROM
    cte c
    JOIN members m2 ON c.customer_id = m2.customer_id
WHERE
    c.row_id = 1
    AND c.order_date < m2.join_date;


-- Question 8:
-- What is the total items and amount spent for each member before they became a member?

-- I used COUNT DISTINCT and SUM to get to the answer:
SELECT
    s.customer_id,
    COUNT(DISTINCT m.product_name) AS number_of_items,
    SUM(m.price) AS Total
FROM
    sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members m1 ON m1.customer_id = s.customer_id
WHERE
    s.order_date < m1.join_date
GROUP BY
    s.customer_id;

-- Question 9:
-- If each $1 spent equates to 10 points and suchi has a 2x points multiplier - how many points would each customer have?

-- using SUM with CASE function:

select s.customer_id, 
sum(
case
when m.product_name = 'sushi' then 20 * price
else 10 * price
end
) as Points
from sales s 
join menu m 
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id 
;


-- Question 10:
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of january?

-- Same query as the last question, using SUM with case function, but this time limiting the date:

select s.customer_id, 
sum(
case
		when m.product_name = 'sushi' then 20 * price
		when order_date between '2024-01-07' AND '2024-01-14' THEN 20 * price
  		ELSE 10 * PRICE
		end
) as Points
from sales s 
join menu m 
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id 
;
