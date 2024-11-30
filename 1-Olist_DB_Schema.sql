-- Drop tables if they exist for re-creation (optional, uncomment to use)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductTranslations;
DROP TABLE IF EXISTS Sellers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Geolocation;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Reviews;


-- Table for Geolocation
CREATE TABLE Geolocation (
    id INT IDENTITY(1,1) PRIMARY KEY,                       		-- Auto-incrementing primary key
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL UNIQUE,     	-- Zip Code Prefix
    geolocation_lat DECIMAL(18, 15) NOT NULL,               		-- Latitude
    geolocation_lng DECIMAL(18, 15) NOT NULL,               		-- Longitude
    geolocation_city NVARCHAR(100) NOT NULL,                		-- City
    geolocation_state CHAR(2) NOT NULL                      		-- State abbreviation
);

-- Table for Customers
CREATE TABLE Customers (
    id INT IDENTITY(1,1) PRIMARY KEY,                        -- Auto-incrementing primary key
    customer_id NVARCHAR(50) NOT NULL,                      -- Customer ID
    customer_unique_id NVARCHAR(50) NOT NULL,               -- Customer Unique ID
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,         -- Zip Code Prefix
    customer_city NVARCHAR(100) NOT NULL,                   -- City
    customer_state CHAR(2) NOT NULL,                        -- State abbreviation
    CONSTRAINT UC_Customers UNIQUE (customer_id)            -- Ensure customer_id is unique
);

-- Add foreign key constraint between Customers and Geolocation tables
ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Geolocation
FOREIGN KEY (customer_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix);

-- Create the Orders table
CREATE TABLE Orders (
    id INT IDENTITY(1,1) PRIMARY KEY,                        -- Auto-incrementing primary key
    order_id NVARCHAR(50) NOT NULL UNIQUE,                  -- Unique Order ID
    customer_id NVARCHAR(50) NOT NULL,                      -- Customer ID (foreign key to Customers table)
    order_status NVARCHAR(20) NOT NULL,                     -- Order Status (e.g., delivered, invoiced)
    order_purchase_timestamp DATETIME NOT NULL,             -- Timestamp of order purchase
    order_approved_at DATETIME NULL,                         -- Timestamp of order approval (nullable)
    order_delivered_carrier_date DATETIME NULL,             -- Timestamp of delivery to carrier (nullable)
    order_delivered_customer_date DATETIME NULL,            -- Timestamp of delivery to customer (nullable)
    order_estimated_delivery_date DATETIME NOT NULL,        -- Estimated delivery date
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) -- Foreign key constraint
);

-- Create the Payments table
CREATE TABLE Payments (
    id INT IDENTITY(1,1) PRIMARY KEY,                       -- Auto-incrementing primary key
    order_id NVARCHAR(50) NOT NULL,                        -- Order ID (foreign key to Orders table)
    payment_sequential INT NOT NULL,                        -- Sequential payment number
    payment_type NVARCHAR(20) NOT NULL,                     -- Type of payment (e.g., credit_card)
    payment_installments INT NOT NULL,                       -- Number of installments
    payment_value DECIMAL(10, 2) NOT NULL,                  -- Payment value
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) -- Foreign key constraint
);

-- Create the Reviews table
CREATE TABLE Reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,                       -- Auto-incrementing primary key
    review_id NVARCHAR(50) NOT NULL,                        -- Original review ID
    order_id NVARCHAR(50) NOT NULL,                         -- Order ID (foreign key to Orders table)
    review_score INT NOT NULL,                             -- Review score (e.g., 1-5)
    review_comment_title NVARCHAR(255) NULL,               -- Title of the review (nullable)
    review_comment_message NVARCHAR(MAX) NULL,             -- Review message (nullable)
    review_creation_date DATETIME NOT NULL,                -- Date when the review was created
    review_answer_timestamp DATETIME NULL,                  -- Timestamp when the review was answered (nullable)
    CONSTRAINT FK_Reviews_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) -- Foreign key constraint
);

-- Create the Products table
CREATE TABLE Products (
    id INT IDENTITY(1,1) PRIMARY KEY,                       -- Auto-incrementing primary key
    product_id NVARCHAR(50) NOT NULL UNIQUE,               -- Unique Product identifier
    product_category_name NVARCHAR(50) NULL,           -- Product category
    product_name_length INT  NULL,                       -- Length of the product name
    product_description_length INT  NULL,                -- Length of the product description
    product_photos_qty INT  NULL,                        -- Quantity of product photos
    product_weight_g INT NULL,                          -- Weight in grams
    product_length_cm INT NULL,                         -- Length in centimeters
    product_height_cm INT NULL,                         -- Height in centimeters
    product_width_cm INT NULL,                          -- Width in centimeters
);

-- Create the Sellers table
CREATE TABLE Sellers (
    id INT IDENTITY(1,1) PRIMARY KEY,                      -- Auto-incrementing primary key
    seller_id NVARCHAR(50) NOT NULL UNIQUE,                -- Original seller ID (unique)
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,          -- Seller zip code prefix
    seller_city NVARCHAR(100) NOT NULL,                    -- Seller city
    seller_state CHAR(2) NOT NULL,                         -- Seller state abbreviation
    CONSTRAINT FK_Sellers_Geolocation FOREIGN KEY (seller_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix) -- Foreign key to Geolocation
);

-- Create the OrderItems table
CREATE TABLE OrderItems (
    id INT IDENTITY(1,1) PRIMARY KEY,                       -- Auto-incrementing primary key
    order_id NVARCHAR(50) NOT NULL,                        -- Foreign key to Orders table
    order_item_id INT NOT NULL,                            -- Unique item identifier for the order
    product_id NVARCHAR(50) NOT NULL,                      -- Product identifier
    seller_id NVARCHAR(50) NOT NULL,                       -- Seller identifier
    shipping_limit_date DATETIME NOT NULL,                 -- Shipping limit date
    price DECIMAL(10, 2) NOT NULL,                         -- Price of the item
    freight_value DECIMAL(10, 2) NOT NULL,                 -- Freight value for the item
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id), -- Foreign key constraint
	CONSTRAINT FK_Products_OrderItems FOREIGN KEY (product_id) REFERENCES Products(product_id), -- Foreign key constraint
	CONSTRAINT FK_Sellers_OrderItems FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id) -- Foreign key to OrderItems
);

-- Create the ProductTranslations table
CREATE TABLE ProductTranslations (
    id INT IDENTITY(1,1) PRIMARY KEY,                       -- Auto-incrementing primary key
    product_category_name NVARCHAR(50) NOT NULL UNIQUE,    -- Original product category name (unique)
    product_category_name_english NVARCHAR(50) NOT NULL    -- English translation of the product category name
);