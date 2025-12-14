
-- ==============================================
-- Swiggy KPI Dashboard Database Script
-- ==============================================

-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS FoodDeliveryDB;
USE FoodDeliveryDB;

-- Step 2: Create Tables

CREATE TABLE IF NOT EXISTS Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    membership_status VARCHAR(50),
    satisfaction_score DECIMAL(3,2)
);

CREATE TABLE IF NOT EXISTS Restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(100),
    category VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS DeliveryAgents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(100),
    is_active BOOLEAN
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    agent_id INT,
    order_date DATETIME,
    order_amount DECIMAL(10,2),
    delivery_time DATETIME,
    expected_delivery_time DATETIME,
    order_status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id),
    FOREIGN KEY (agent_id) REFERENCES DeliveryAgents(agent_id)
);

-- Step 3: Insert Sample Data

INSERT INTO Customers (customer_name, membership_status, satisfaction_score) VALUES
('Alice', 'Gold', 4.8),
('Bob', 'Silver', 4.2),
('Charlie', 'Gold', 4.9),
('David', 'Regular', 3.9),
('Eva', 'Regular', 4.1);

INSERT INTO Restaurants (restaurant_name, category) VALUES
('Spicy House', 'Indian'),
('Pasta Point', 'Italian'),
('Sushi Star', 'Japanese'),
('Burger Hub', 'American'),
('Taco Time', 'Mexican');

INSERT INTO DeliveryAgents (agent_name, is_active) VALUES
('Ravi', TRUE),
('Suman', TRUE),
('Karan', FALSE),
('Neha', TRUE),
('Amit', TRUE);

INSERT INTO Orders (customer_id, restaurant_id, agent_id, order_date, order_amount, delivery_time, expected_delivery_time, order_status) VALUES
(1, 1, 1, '2024-10-01 12:00:00', 550.00, '2024-10-01 12:45:00', '2024-10-01 13:00:00', 'Delivered'),
(2, 2, 2, '2024-10-02 13:00:00', 700.00, '2024-10-02 13:40:00', '2024-10-02 14:00:00', 'Delivered'),
(3, 3, 3, '2024-10-03 18:00:00', 1200.00, '2024-10-03 18:55:00', '2024-10-03 19:00:00', 'Delivered'),
(4, 4, 4, '2024-10-04 19:00:00', 450.00, '2024-10-04 19:50:00', '2024-10-04 19:40:00', 'Cancelled'),
(5, 5, 5, '2024-10-05 20:00:00', 850.00, '2024-10-05 20:45:00', '2024-10-05 21:00:00', 'Delivered');

-- Step 4: KPI Queries

-- 1. Total Customers
SELECT COUNT(DISTINCT customer_id) AS Total_Customers FROM Customers;

-- 2. Total Revenue
SELECT SUM(order_amount) AS Total_Revenue FROM Orders WHERE order_status = 'Delivered';

-- 3. Delivery Efficiency
SELECT (SUM(CASE WHEN delivery_time <= expected_delivery_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Delivery_Efficiency_Percent FROM Orders WHERE order_status = 'Delivered';

-- 4. Top Performing Restaurants
SELECT r.restaurant_name, SUM(o.order_amount) AS Total_Revenue FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name ORDER BY Total_Revenue DESC LIMIT 5;

-- 5. Membership Status
SELECT membership_status, COUNT(*) AS Total_Customers FROM Customers GROUP BY membership_status;

-- 6. Order Cancellation Rate
SELECT (SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Cancellation_Rate_Percent FROM Orders;

-- 7. Customer Satisfaction Score (CSS)
SELECT ROUND(AVG(satisfaction_score), 2) AS Avg_Customer_Satisfaction_Score FROM Customers;

-- 8. Active Delivery Agents
SELECT COUNT(*) AS Active_Delivery_Agents FROM DeliveryAgents WHERE is_active = TRUE;

-- 9. Average Delivery Time
SELECT ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_date, delivery_time)), 2) AS Avg_Delivery_Time_Minutes FROM Orders WHERE order_status = 'Delivered';

-- 10. Top Food Categories
SELECT r.category AS Food_Category, SUM(o.order_amount) AS Total_Revenue FROM Orders o
JOIN Restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.category ORDER BY Total_Revenue DESC LIMIT 5;
