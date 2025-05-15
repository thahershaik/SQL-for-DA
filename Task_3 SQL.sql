-- Create and use the database
CREATE DATABASE IF NOT EXISTS Ecommerce_SQL_Database;
USE Ecommerce_SQL_Database;

-- Customers table
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    registration_date DATE
);

INSERT INTO customer VALUES
(1, 'Alice', 'alice@example.com', 'Delhi', '2023-01-10'),
(2, 'Bob', 'bob@example.com', 'Mumbai', '2023-02-15'),
(3, 'Charlie', 'charlie@example.com', 'Bangalore', '2023-03-20'),
(4, 'Diana', 'diana@example.com', 'Chennai', '2023-04-05');

-- Products table
CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);

INSERT INTO product VALUES
(1, 'Laptop', 'Electronics', 75000.00, 50),
(2, 'Mouse', 'Electronics', 500.00, 200),
(3, 'Chair', 'Furniture', 3000.00, 100),
(4, 'Notebook', 'Stationery', 40.00, 500);

-- Orders table
CREATE TABLE orderss (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orderss VALUES
(101, 1, '2024-01-05', 75500.00),
(102, 2, '2024-01-10', 1000.00),
(103, 1, '2024-01-12', 200.00),
(104, 3, '2024-01-15', 3000.00);

-- Order Items table
CREATE TABLE order_item (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    item_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_item VALUES
(1, 101, 1, 1, 75000.00),
(2, 101, 2, 1, 500.00),
(3, 102, 2, 2, 500.00),
(4, 103, 4, 5, 40.00),
(5, 104, 3, 1, 3000.00);

select * from customer;
select * from product;
select * from orderss;
select * from order_item;
-- List all products with a price greater than ₹1,000, ordered by price descending.
SELECT 
    product_name
FROM
    product
WHERE
    price > 1000
ORDER BY price DESC;

-- Show total number of customers grouped by city.
SELECT 
    city, COUNT(*) AS total_customers
FROM
    customer
GROUP BY city;

-- Get all orders with total amount above ₹5,000, ordered by order date.
SELECT 
    *
FROM
    orderss
WHERE
    total_amount > 5000
ORDER BY order_date;

-- List all order IDs with corresponding customer names using INNER JOIN. 
SELECT order_id,name from orderss join customer on orderss.customer_id=customer.customer_id;

-- Get a list of all customers and their orders using LEFT JOIN (include customers with no orders).
SELECT  name AS customer_name, order_id, order_date,total_amount
FROM customer
LEFT JOIN orderss ON customer.customer_id = orderss.customer_id;

-- Find all orders and their product names using RIGHT JOIN.
select order_id,product_name from order_item right join product on order_item.product_id=product.product_id;

-- Find customers who spent more than the average total order amount.
SELECT 
    name
FROM
    customer
        JOIN
    orderss ON customer.customer_id = orderss.customer_id
WHERE
    total_amount > (SELECT 
            AVG(total_amount)
        FROM
            orderss);
-- List products whose price is higher than the average product price.
SELECT 
    product_name,
    price,
    (SELECT AVG(price) FROM product) AS average_price
FROM
    product
WHERE
    price > (SELECT AVG(price) FROM product);

-- Show names of customers who placed more orders than the customer 'Bob'.
SELECT 
    c.name
FROM
    customer c
        JOIN
    orderss o ON c.customer_id = o.customer_id
GROUP BY c.customer_id , c.name
HAVING COUNT(o.order_id) > (SELECT 
        COUNT(*)
    FROM
        orderss o2
            JOIN
        customer c2 ON o2.customer_id = c2.customer_id
    WHERE
        c2.name = 'Bob'); 
 
--  Calculate the total revenue from all orders.
SELECT sum(item_price * quantity) as total_price from order_item;

-- Find the average order amount per customer.
SELECT 
    c.name, round(AVG(o.total_amount),2) AS Average_amount
FROM
    customer c
        JOIN
    orderss o ON c.customer_id = o.customer_id
GROUP BY c.customer_id , c.name; 

-- Get the product with the highest average item price in order items.
SELECT 
    p.product_name, AVG(o.item_price) AS avg_price
FROM
    product p
        JOIN
    order_item o ON o.product_id = p.product_id
GROUP BY p.product_id , p.product_name
ORDER BY avg_price DESC
LIMIT 1;

-- Create a view named high_value_orders showing orders with total amount > ₹10,000.
create view high_value_orders as 
select * from orderss where total_amount > 10000;

select * from high_value_orders;

-- Create a view customer_sales_summary showing each customer's total spending.
create view customer_sales_summary as 
SELECT c.customer_id,c.name,sum(o.total_amount) from customer c join orderss o ON o.customer_id=c.customer_id group by c.customer_id,c.name;
select * from customer_sales_summary;
-- Create an index on orders(order_date) to improve date filtering.

CREATE INDEX idx_order_date ON orderss(order_date);
SHOW INDEX FROM orderss;

-- Create a composite index on order_items(order_id, product_id) to improve join performance.
CREATE INDEX idx_order_product ON order_items(order_id, product_id);
show index from order_item;



