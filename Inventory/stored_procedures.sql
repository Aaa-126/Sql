-- stored procedures

DELIMITER |
-- to manually calculate min_required,based on lead_time and avg_daily_usage for a item to lessen the chances of stock out and also updating min_supplier
CREATE PROCEDURE calculate_min_required_based_lead_times()
BEGIN
	
    DECLARE min_lead_time_ INT;
    DECLARE item_id_ INT;
    DECLARE avg_usg_ INT;
    DECLARE supplier_id_ INT;
    DECLARE done BOOLEAN;
    
    DECLARE cur CURSOR FOR 
    SELECT item_id, avg_usage FROM inventory_items;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    loop_ : LOOP
    
    FETCH cur INTO item_id_, avg_usg_;
    
    -- if cur is at last
    if done THEN 
    LEAVE loop_;
    END IF;
    -- -----------------
    
    -- selectin' min_lead_time for a item id
    SELECT supplier_id, lead_time_days INTO supplier_id_, min_lead_time_
    WHERE item_id = item_id_
    ORDER BY lead_time_days ASC
    LIMIT 1;
    -- -------------------------------------
    
		
    
    -- update reorder_rules
    UPDATE reorder_rules
    SET supplier_id = supplier_id_ AND min_required = avg_usg_ * min_lead_time
    WHERE item_id = item_id_;
    -- -------------------------------------
    
    END LOOP loop_;
    CLOSE cur;
END |
DELIMITER ;

-- to manually check if the item health - including expiry-date along with reminder to check physically for items based on review frequency and last review, this will be batch wise
DELIMITER |
-- checks expiry
CREATE PROCEDURE check_expiry()
BEGIN
	DECLARE done BOOLEAN;
	DECLARE item_id_ INT;
    DECLARE batch_id_ INT;
    DECLARE expiry_date_ DATE;
    DECLARE qty_ INT;
    DECLARE item_nearest_expiry_ INT;
    DECLARE nearest_expiry_date_ DATE DEFAULT NULL;
    
    DECLARE cur CURSOR FOR
    SELECT batch_id, item_id, expiry_date, quantity FROM inventory_batches;
    
    DECLARE CONTiNUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    loop_: LOOP
			
	 FETCH cur INTO batch_id_, item_id_, expiry_date_, qty_;
     
     -- if cur is at last
    if done THEN 
    LEAVE loop_;
    END IF;
    -- -----------------
     
     IF expiry_date_ IS NOT NULL THEN
		IF expiry_date_ < DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY) THEN
			INSERT INTO inventory_actions (item_id, action_type, batch_id,quantity, message)
            VALUES (item_id, "EXPIRE", batch_id_,qty, CONCAT("product expired", CAST(expiry_date_ AS CHAR)));
		ELSEIF expiry_date_ = DATE_ADD(CURRETN_DATE, INTERVAL 1 DAY) THEN
			INSERT INTO inventory_actions (item_id, action_type, batch_id,quantity, message)
            VALUES (item_id, "EXPIRE", batch_id_,qty, CONCAT("product expiring tomorrow", CAST(expiry_date_ AS CHAR)));
		END IF;
        -- we can further add importance feature if we want
        
        -- ----------------------------------------------
     END IF;
	
    END LOOP loop_;
    CLOSE cur;

END|

DELIMITER ;

-- check review needing items
DELIMITER |

CREATE PROCEDURE check_review()
BEGIN
	DECLARE item_id_ INT;
	DECLARE last_review_ DATE;
    DECLARE freq_ INT;
    DECLARE due_date_ DATE;
    DECLARE done BOOLEAN;
    
    DECLARE cur CURSOR FOR
    SELECT item_id, last_review_date, review_frequency_days FROM reorder_rules;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    
    loop_: LOOP
    FETCH cur INTO item_id_, last_review_, freq_;
    
    -- if cur is at last
    if done THEN 
    LEAVE loop_;
    END IF;
    -- -----------------
    SET due_date_ = DATE_ADD(last_review_, INTERVAL freq_ DAY);

        -- If review is due
	IF CURDATE() >= due_date THEN
		INSERT INTO inventory_actions (item_id, action_type, message)
		VALUES (item_id_, 'REVIEW', CONCAT('Reorder review due on ', CAST(due_date_ AS CHAR)));
	END IF;
    
    
    END LOOP loop_;
    
    CLOSE cur;
    
END|
DELIMITER ;
-- to maually check if inventory relations like every item has a supplier, 
DELIMITER |

CREATE PROCEDURE items_with_no_supplier()
BEGIN
	DECLARE done BOOLEAN;
    DECLARE item_id_ INT;
    
    DECLARE cur CURSOR FOR
	SELECT item_id FROM inventory_items;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;
    
    loop_ : LOOP
    
		FETCH cur into item_id_;
        
        IF NOT EXISTS (SELECT * FROM supplier_items WHERE item_id = item_id_) THEN
			INSERT INTO inventory_recommend (item_id, message)
            VALUES (item_id_, "no supplier for this item_id_");
		END IF;
	
    END LOOP loop_;
    CLOSE cur;

END|
DELIMITER ;

-- to manually update avg_usage depend on "manager/ reviewer" may be monthly or yearly or weekly depend further on festives
-- DROP PROCEDURE update_avg_usage;
DELIMITER |

CREATE PROCEDURE update_avg_usage(IN inter_ INT)
BEGIN

	-- it will be further update after creating supplier_log view and consumer_log view;
    DECLARE done BOOLEAN;
    DECLARE item_id_ INT;
    DECLARE total_qty_ INT;
    
    DECLARE cur CURSOR FOR 
    SELECT item_id, SUM(quantity)
    FROM consumer_log
    WHERE DATE(transaction_date) >= CURRENT_DATE - INTERVAL inter_ day
    GROUP BY item_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur;
    
    usage_loop: LOOP
        FETCH cur INTO item_id_, total_qty_;
        IF done THEN
            LEAVE usage_loop;
        END IF;
        
        UPDATE inventory_items
        SET avg_daily_usage = (total_qty_ / inter_)
        WHERE item_id = item_id_;
        
    END LOOP;
    CLOSE cur;

END |

DELIMITER ;

-- calculate min_required based on last year
DELIMITER |

CREATE PROCEDURE calculate_min_required_based_last_year()
BEGIN
	DECLARE done BOOLEAN;
    DECLARE item_id_ INT;
    DECLARE total_qty_ INT;
    DECLARE supplier_id_ INT;
    DECLARE min_lead_time_ INT;
    
    DECLARE cur CURSOR FOR 
    SELECT item_id, SUM(quantity)
    FROM consumer_log
    WHERE DATE(transaction_date) >= CURRENT_DATE - INTERVAL 1 YEAR - INTERVAL 7 day
    GROUP BY item_id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur;
    loop_: LOOP
		
        FETCH cur INTO item_id_, total_qty_;
		IF done THEN
			LEAVE usage_loop;
		END IF;
        
         -- selectin' min_lead_time for a item id
		SELECT supplier_id, lead_time_days INTO supplier_id_, min_lead_time_
		WHERE item_id = item_id_
		ORDER BY lead_time_days ASC
		LIMIT 1;
		-- -------------------------------------
        
        UPDATE reorder_rules
        SET min_required = min_lead_time_ * (total_qty_ / 7);
    
    END LOOP loop_;
    
END |
DELIMITER ;