/* PROJECT DESCRIPTION
George wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money
they have spent and also which menu items are their favourites. Having this deeper connection with his customers will help him deliver
a better and more personalized experience for his loyal customers. */

USE RestaurantDB;

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    JoinDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE MenuItems (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    DetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ItemID INT,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);

INSERT INTO Customers (Name, Email, Phone) VALUES
('John Doe', 'john.doe@example.com', '1234567890'),
('Jane Smith', 'jane.smith@example.com', '0987654321'),
('Bob Johnson', 'bob.johnson@example.com', '1122334455');

SELECT *
FROM CUSTOMERS;

INSERT INTO MenuItems (ItemName, Category, Price) VALUES
('Cheeseburger', 'Main Course', 8.99),
('Caesar Salad', 'Appetizer', 5.99),
('Chocolate Cake', 'Dessert', 6.49),
('Latte', 'Beverage', 3.99);

SELECT *
FROM MENUITEMS;

INSERT INTO Orders (CustomerID, OrderDate) VALUES
(1, '2025-01-20'),
(2, '2025-01-21'),
(1, '2025-01-25');

SELECT *
FROM ORDERS;

INSERT INTO OrderDetails (OrderID, ItemID, Quantity) VALUES
(1, 1, 2), -- John Doe ordered 2 Cheeseburgers
(1, 3, 1), -- John Doe ordered 1 Chocolate Cake
(2, 2, 1), -- Jane Smith ordered 1 Caesar Salad
(2, 4, 2), -- Jane Smith ordered 2 Lattes
(3, 1, 1), -- John Doe ordered 1 Cheeseburger
(3, 4, 1); -- John Doe ordered 1 Latte

SELECT *
FROM ORDERDETAILS;

-- Most frequent visitors
SELECT Customers.Name, COUNT(Orders.OrderID) AS TotalOrders
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID
ORDER BY TotalOrders DESC;

-- Average time between visits
SELECT 
    c.Name,
    AVG(DATEDIFF(o1.OrderDate, o2.OrderDate)) AS AvgDaysBetweenVisits
FROM Orders o1
LEFT JOIN Orders o2
  ON o1.CustomerID = o2.CustomerID
  AND o1.OrderDate > o2.OrderDate
JOIN Customers c
  ON o1.CustomerID = c.CustomerID
WHERE o2.OrderDate IS NOT NULL  -- Exclude the first visit (no prior order)
GROUP BY c.Name;

-- Total spend 
SELECT Customers.Name, SUM(MenuItems.Price * OrderDetails.Quantity) AS TotalSpend
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN MenuItems ON OrderDetails.ItemID = MenuItems.ItemID
GROUP BY Customers.CustomerID
ORDER BY TotalSpend DESC;

-- High spenders
SELECT Name, TotalSpend
FROM (
    SELECT Customers.Name, SUM(MenuItems.Price * OrderDetails.Quantity) AS TotalSpend
    FROM Customers
    JOIN Orders ON Customers.CustomerID = Orders.CustomerID
    JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
    JOIN MenuItems ON OrderDetails.ItemID = MenuItems.ItemID
    GROUP BY Customers.CustomerID
) AS Spending
WHERE TotalSpend > 10; 

-- Favourite items
SELECT MenuItems.ItemName, SUM(OrderDetails.Quantity) AS TotalOrdered
FROM MenuItems
JOIN OrderDetails ON MenuItems.ItemID = OrderDetails.ItemID
GROUP BY MenuItems.ItemID
ORDER BY TotalOrdered DESC;

-- Customer preferences
SELECT Customers.Name, MenuItems.ItemName, SUM(OrderDetails.Quantity) AS TotalOrdered
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN MenuItems ON OrderDetails.ItemID = MenuItems.ItemID
GROUP BY Customers.CustomerID, MenuItems.ItemID
ORDER BY Customers.Name, TotalOrdered DESC;






