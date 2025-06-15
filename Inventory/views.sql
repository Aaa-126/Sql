

-- complete item detail



-- supplier log
--  VIEW supplier_log;
CREATE VIEW supplier_log AS
SELECT DATE(T.transaction_date), S.supplier_id supplier_id, S.supplier_name, I.item_id item_id, I.item_name item_name, T.quantity, T.total_cost
FROM inventory_items I, suppliers S, stock_transaction T, supplier_items SI
WHERE I.item_id = T.item_id AND T.party_id = S.supplier_id AND S.supplier_id = SI.supplier_id AND I.item_id = SI.item_id AND T.transaction_type = 'IN' ; 

-- consumer log
-- DROP VIEW consumer_log;
CREATE VIEW consumer_log AS
SELECT DATE(T.transaction_date) transaction_date,G.guest_id guest_id,G.guest_name, I.item_id item_id, I.item_name item_name, T.quantity, T.total_cost cost_price, 
T.quantity*I.current_price selling_price 
FROM inventory_items I, guests G, stock_transaction T
WHERE I.item_id = T.item_id AND T.party_id = G.guest_id AND T.transaction_type = 'OUT' ; 


SELECT * FROM consumer_log;
SELECT * FROM supplier_log;
SELECT * FROM stock_transaction;