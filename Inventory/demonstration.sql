

SELECT * FROM inventory_items;
-- ----------------------------
INSERT INTO stock_transaction ( item_id, transaction_type, quantity,total_cost, party_id, expiry_date) VALUES
(1, 'IN', 56, 5600,1,NULL);
-- ---------------------------
INSERT INTO stock_transaction ( item_id, transaction_type, quantity, party_id, expiry_date) VALUES
(1, 'OUT', 67, 1, NULL);
-- ------------------------------


SELECT * FROM inventory_batches;
CALL update_avg_usage(2);
SELECT * FROM inventory_items;

SELECT * FROM consumer_log;
SELECT * FROM supplier_log;
SELECT * FROM stock_transaction;