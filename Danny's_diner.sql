Create database Dannys_diner;
use Dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

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
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- Que-1 What is the total amount each customer spent at the restaurant?
   select s.customer_id,sum(m.price) as Total_spent from sales as s join menu as m
	on s.product_id=m.product_id
    group by s.customer_id order by customer_id ;
    
  -- Que-2 How many days has each customer visited the restaurant?
 select customer_id , count(distinct order_date) as visited_date from sales
 group by customer_id;
 
 -- Que-3 What was the first item from the menu purchased by each customer?
  select s.customer_id,m.product_name from sales as s join menu as m
   on s.product_id=m.product_id
	where (s.customer_id,s.order_date) in (select customer_id,min(order_date) from sales group by customer_id);
    
-- Que-4 What is the most purchased item on the menu and how many times was it purchased by all customers?
 select m.product_name,count(m.product_name) as total_sales from sales as s join menu as m
 on s.product_id=m.product_id
 group by m.product_name
order by total_sales desc limit 1;

-- Que-5 Which item was the most popular for each customer? 
with popular_item as(
select s.customer_id,m.product_name as popular_item,count(*) as ordered_number_of_times,dense_rank() over( partition by s.customer_id order by count(*) desc) as dr from sales as s join menu as m 
on s.product_id=m.product_id
group by s.customer_id,m.product_name)

select customer_id,popular_item,ordered_number_of_times from popular_item
where dr=1;
    
-- Que.6 Which item was purchased first by the customer after they became a member?
with purchase_ranking as (
 select s.customer_id,m.product_name,rank() over(partition by s.customer_id order by s.order_date)  as r from sales as s join menu as m
 on s.product_id=m.product_id
  join members as mem
 on s.customer_id=mem.customer_id and s.order_date>=mem.join_date)
 
 select customer_id,product_name from purchase_ranking
 where r=1;
 
 
 -- Que.7 Which item was purchased just before the customer became a member?
 with purchase_ranking as (
 select s.customer_id,m.product_name,rank() over(partition by s.customer_id order by s.order_date desc)  as r from sales as s join menu as m
 on s.product_id=m.product_id
  join members as mem
 on s.customer_id=mem.customer_id and s.order_date<mem.join_date)
 
 select customer_id,product_name from purchase_ranking
 where r=1;

 
 -- Que.8 What is the total items and amount spent for each member before they became a member?
 select s.customer_id,count(s.product_id) as total_items ,sum(m.price) as total_amount from sales as s join menu as m
  on s.product_id=m.product_id
   join members as e
  on e.customer_id=s.customer_id and s.order_date<e.join_date
  group by s.customer_id;

-- Que. 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,
sum(case when m.product_name="sushi"
then  20*m.price
else m.price*10 end) as total_points from sales as s join menu as m
on s.product_id=m.product_id
group by s.customer_id;

-- Que. 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id,
sum(case
when s.order_date between e.join_date and DATE_ADD(e.join_date, INTERVAL 6 DAY)
then 20*m.price
 when m.product_name="sushi"
then  20*m.price
else m.price*10 end) as total_points from sales as s join menu as m
on s.product_id=m.product_id
  join members as e
on e.customer_id=s.customer_id
where s.order_date<="2021-01-31"
group by s.customer_id;

-- creating the bonus table

create table if not exists customer_order
select s.customer_id,s.order_date,m.product_name,m.price,
case when s.customer_id=mem.customer_id and s.order_date>=mem.join_date
then "Y"
else "N" end as member
  from sales as s left join menu as m
on s.product_id=m.product_id
left join members as mem 
on s.customer_id=mem.customer_id;

select * from customer_order;

-- bonus solution

select * ,
case when member="N" then null 
else dense_rank() over(partition by customer_id,member order by order_date) end as ranking
from customer_order ;













