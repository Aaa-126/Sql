
-- log for if inventory need immediate action
-- DROP TABLE inventory_actions;
CREATE TABLE inventory_actions(
	log_id INT AUTO_INCREMENT PRIMARY KEY,
	item_id INT,
    action_type ENUM ('REVIEW', 'STOCK', 'EXPIRE') NOT NULL,
    batch_id INT DEFAULT NULL,
    log_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    quantity INT DEFAULT NULL,
    message VARCHAR(100) DEFAULT "no message",
    
    FOREIGN KEY(item_id) REFERENCES inventory_items(item_id) 
);

-- notification log recommended actions
CREATE TABLE inventory_recommend(
	item_id INT,
    message VARCHAR(200),
    
    FOREIGN KEY(item_id) REFERENCES inventory_items(item_id)
);




