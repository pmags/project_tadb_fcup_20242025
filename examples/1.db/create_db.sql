-- Creating a table called 'products'
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,       -- Auto-incrementing primary key for each product
    product_name VARCHAR(255) NOT NULL,   -- Name of the product
    description TEXT,                     -- Description of the product
    price DECIMAL(10, 2) NOT NULL,        -- Price of the product (2 decimal places)
    stock_quantity INT DEFAULT 0,         -- Quantity of the product in stock (defaults to 0)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp for when the product was added
);

