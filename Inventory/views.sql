

-- complete item detail
-- DROP VIEW item_summary;
CREATE VIEW item_summary AS 
SELECT 
	I.item_id item_id,
    I.item_name item_name,
    I.unit unit,
    I.current_stock current_stock,
    I.avg_daily_usage avg_dail_usage,
    RR.min_required min_required,
    RR.last_review_date last_review_date,
    RR.review_frequency_days review_freq,
    (SELECT SS.party_id FROM stock_transaction SS WHERE SS.item_id = I.item_id AND SS.is_valid = 1 AND SS.transaction_type = 'IN' ORDER BY SS.transaction_date DESC LIMIT 1) last_supplier_id,
    (SELECT SU.supplier_name FROM stock_transaction SS, suppliers SU WHERE SS.item_id = I.item_id AND SS.is_valid = 1 AND SS.transaction_type = 'IN' AND SS.party_id = SU.supplier_id ORDER BY SS.transaction_date DESC LIMIT 1) last_supplier_name,
    (SELECT SS.transaction_date FROM stock_transaction SS WHERE SS.item_id = I.item_id AND SS.is_valid = 1 AND SS.transaction_type = 'IN' ORDER BY SS.transaction_date DESC LIMIT 1) last_supplied_date,
    (SELECT SS.quantity FROM stock_transaction SS WHERE SS.item_id = I.item_id AND SS.is_valid = 1 AND SS.transaction_type = 'IN' ORDER BY SS.transaction_date DESC LIMIT 1) last_supplied_quantity
FROM inventory_items I, reorder_rules RR
WHERE I.item_id = RR.item_id ;



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
SELECT * FROM item_summary;