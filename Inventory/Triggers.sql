
USE hotel;


-- as the name suggesting it is validating the transaction
-- DROP TRIGGER validate_transaction;
DELIMITER |
CREATE TRIGGER validate_transaction
BEFORE INSERT ON stock_transaction
FOR EACH ROW
BEGIN
	DECLARE curr_qty INT;
    DECLARE party_count INT;
    -- variable to update tables
    DECLARE min_level INT;
    DECLARE curr_level INT;
    DECLARE expiry_ DATE;
    
    -- -----------------------------------------------
    
    -- validating part
    SELECT current_stock INTO curr_qty
    FROM inventory_items 
    WHERE item_id = NEW.item_id;
    
	IF NEW.transaction_type = "OUT" THEN
		SELECT COUNT(*) INTO party_count FROM guests WHERE guest_id = NEW.party_id; 
        
        IF party_count = 0 THEN
			SET NEW.is_valid = 0;
            SET NEW.message = "invalid guest id";
		ELSEIF NEW.quantity > curr_qty THEN
		SET NEW.is_valid = 0;
        SET NEW.message = "insufficient stocks";
        END IF;
        
	ELSEIF NEW.transaction_type = "ADJUSTMENT" AND NEW.quantity + curr_qty < 0 THEN
		SET NEW.is_valid = 0;
        SET NEW.message = "stock will be megative";
        
	ELSEIF NEW.transaction_type = 'IN' THEN
		SELECT COUNT(*) INTO party_count FROM suppliers WHERE supplier_id = NEW.party_id;
        IF party_count = 0 THEN
			SET NEW.is_valid = 0;
            SET NEW.message = "invalid supplier id";
		END IF;
	END IF;
    -- ----------------------------------------------------------------------------------validate part ends
    -- if valid setting some value fofr the new.row 
    IF NEW.is_valid = 1 THEN
    IF NEW.transaction_type = 'OUT' THEN
		UPDATE inventory_items
        SET current_stock = current_stock - NEW.quantity
        WHERE item_id = NEW.item_id;
        
        -- logging iventory_acitons if item needed immediate replenshment
		SELECT min_required INTO min_level 
        FROM reorder_rules
        WHERE item_id = NEW.item_id;
        
        SELECT current_stock INTO curr_level
        FROM inventory_items
        WHERE item_id = NEW.item_id;
        
        if curr_level < min_level THEN 
			INSERT INTO inventory_actions (item_id, message)
            VALUES (NEW.item_id, "stock level is below minimum requirement");
		END IF;
		-- ------------------------------------------------------------------
	-- ------------------------------------------------------------------
	ELSEIF NeW.transaction_type = 'IN' THEN
		-- UPDATING inventory_items
		UPDATE inventory_items
        SET current_stock = current_stock + NEW.quantity
        WHERE item_id = NEW.item_id;
	END IF;
    
     CALL update_batches(NEW.transaction_type, NEW.item_id, NEW.quantity, NEW.total_cost, CURRENT_DATE, NEW.expiry_date);
	END IF;
	-- -------------------------------------------update part ends
END |

DELIMITER ;




-- updating tables- inventory_items, inventory_batches



-- procedure to update inventory_batches
-- DROP PROCEDURE update_batches;
DELIMITER |
CREATE PROCEDURE update_batches(
	IN t_type ENUM('IN', 'OUT', 'ADJUSTMENT'),
	IN item_id_ INT,
    IN quantity_ INT,
    INOUT total_cost_ INT,
    IN arrival_date_ INT,
    IN expiry_date_ INT
    
)
BEGIN
	DECLARE batch_id_ INT;
	DECLARE min_expiry_batch_id INT;
    DECLARE available_qty INT;
    DECLARE remaining_qty INT;
    DECLARE total_cost_price_ INT DEFAULT 0;
    DECLARE batch_cost_ INT;
    
	IF t_type = 'IN' THEN
		-- UPDATING inventory_batches
        INSERT INTO inventory_batches (item_id, quantity,total_cost, arrival_date, expiry_date)
        VALUES (item_id_, quantity_,total_cost_,arrival_date_, expiry_date_);
	
    ELSEIF t_type = 'OUT' THEN
		SET remaining_qty = quantity_;
		loop_: WHILE remaining_qty > 0 DO
        
			SELECT batch_id, quantity, total_cost INTO min_expiry_batch_id, available_qty, batch_cost_ FROM inventory_batches
			WHERE item_id = item_id_ AND quantity > 0 
            ORDER BY expiry_date ASC
            LIMIT 1;
			
            IF min_expiry_batch_id IS NULL THEN
				LEAVE loop_;
			END IF;
            
            IF available_qty <= remaining_qty THEN
				SET remaining_qty = remaining_qty - available_qty;
                DELETE FROM inventory_batches 
                WHERE batch_id = min_expiry_batch_id;
                
                SET total_cost_price_ = total_cost_price_ + batch_cost_;
			ELSE
				SET total_cost_price_ = total_cost_price_ + remaining_qty*(batch_cost_ / available_qty);
				SET remaining_qty = 0;
                UPDATE inventory_batches
                SET quantity = available_qty - remaining_qty AND total_cost = (batch_cost_ - (batch_cost_ / available_qty)*remaining_qty)
                WHERE batch_id = min_expiry_batch_id;
                
			END IF;
            
		END WHILE loop_;
        
        SET total_cost_ = total_cost_price_;
	
    END IF;

END |

DELIMITER ;



