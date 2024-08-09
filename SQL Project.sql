create database pizzahut;

use pizzahut;

select * from pizza_types;
select * from pizzas;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

select * from orders;

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

select * from order_details;

## 1)Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_number
FROM
    pizzahut.orders;

## 2)Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
## 3)Identify the highest-priced pizza.
SELECT 
    pizza_types.pizza_type_id, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

## 4)Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

## 5)List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

##6)Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY (pizza_types.category);

##7)Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id) AS Total_orders
FROM
    orders
GROUP BY HOUR(order_time);

##8)Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY (category);

##9)Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as Avg_number_of_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date AS date,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY (date)) AS Total_quantity_per_day;
    

##10)Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revanue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY (pizza_types.name)
ORDER BY (revanue) DESC
LIMIT 3;

##11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price)/ (SELECT 
            ROUND(SUM(pizzas.price * order_details.quantity),
                        2) AS Tptal_Sales
        FROM
            pizzas
                JOIN
            order_details ON pizzas.pizza_id = order_details.pizza_id)*100,2) AS revanue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY (pizza_types.category);

##12)Analyze the cumulative revenue generated over time.
SELECT order_date, total_revenue, SUM(total_revenue) over(order by order_date) as cum_revenue from
(SELECT 
    orders.order_date,
    ROUND(SUM(order_details.quantity * pizzas.price),
            0) AS total_revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY orders.order_date) as sales;


##13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category, pizza_types.name, round(sum(order_details.quantity*pizzas.price),0) as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id join order_details
on order_details.pizza_id=pizzas.pizza_id group by pizza_types.category, pizza_types.name) as a) as b where rn<=3;










