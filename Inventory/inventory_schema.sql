


-- drop database hotel;
CREATE DATABASE hotel;
USE hotel;

CREATE TABLE inventory_items(
	item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100),
    category VARCHAR(50),
    current_stock INT NOT NULL DEFAULT 0,
    unit VARCHAR(20),
    current_price DECIMAL(10, 2),
    avg_daily_usage INT
);

CREATE TABLE inventory_batches(
    batch_id INT AUTO_INCREMENT,
    item_id INT,
    quantity INT NOT NULL,
    total_cost INT,
    arrival_date DATE NOT NULL,
    expiry_date DATE,
    PRIMARY KEY(batch_id),
    FOREIGN KEY(item_id) REFERENCES inventory_items(item_id) ON DELETE CASCADE
    
);

CREATE TABLE reorder_rules(
	item_id INT PRIMARY KEY,
    reorder_quantity INT NOT NULL,
    safety_stock INT NOT NULL,
    min_required INT NOT NULL DEFAULT 0,
    max_stock_level INT,
    review_frequency_days INT,
    last_review_date DATE,
    FOREIGN KEY(item_id) REFERENCES inventory_items(item_id) ON DELETE CASCADE 
);

CREATE TABLE suppliers(
	supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(100),
    rating INT
);

CREATE TABLE supplier_items(
		supplier_id INT,
        item_id INT,
        lead_time_days INT,
        PRIMARY KEY(supplier_id, item_id),
        FOREIGN KEY(supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
        FOREIGN KEY(item_id) REFERENCES inventory_items(item_id) ON DELETE CASCADE
);

-- DROP TABLE stock_transaction;
CREATE TABLE stock_transaction(
	transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    -- batch_id INT, 
    transaction_type ENUM('IN', 'OUT', 'ADJUSTMENT') NOT NULL,
    quantity INT NOT NULL,
    total_cost INT,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    party_id INT,
	expiry_date DATE ,
    is_valid SMALLINT DEFAULT 1,
    message VARCHAR(200) DEFAULT "successful",
    FOREIGN KEY(item_id) REFERENCES inventory_items(item_id)
);






-- ------------------------------------------------------------------------------------
set @batch = 1;-- 
DELIMITER |

CREATE FUNCTION NEW_BATCH_ID()
RETURNS INT
DETERMINISTIC
BEGIN
	SET @batch_id = @batch_id + 1;
    RETURN @batch_id;
END|

DELIMITER ;


