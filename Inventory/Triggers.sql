
DELIMITER |

CREATE TRIGGER validate_transaction
BEFORE INSERT ON stock_transaction
FOR EACH ROW
BEGIN
	DECLARE curr_qty INT;
    DECLARE party_count INT;
    
    
    
    
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

END |

DELIMITER ;




DELIMITER |
CREATE TRIGGER update_inventory
AFTER INSERT ON stock_transaction
FOR EACH ROW
BEGIN
	DECLARE batch_id_ INT;
	DECLARE min_expiry_batch_id INT;
    DECLARE available_qty INT;
    DECLARE remaining_qty INT;
    DECLARE min_level INT;
    
    IF NEW.transaction_type = 'OUT' THEN
		UPDATE inventory_items
        SET current_stock = current_stock - NEW.quantity
        WHERE item_id = NEW.item_id;
        
        SET remaining_qty = NEW.quantity;
        
		loop_: WHILE remaining_qty > 0 DO
        
			SELECT batch_id, quantity INTO min_expiry_batch_id, available_qty FROM inventory_batches
			WHERE item_id = NEW.item_id AND quantity > 0 
            ORDER BY expiry_date ASC
            LIMIT 1;
			
            IF batch_id IS NULL THEN
				LEAVE loop_;
			END IF;
            
            IF available_qty <= remaining_qty THEN
				SET remaining_qty = remaining_qty - available_qty;
                UPDATE inventory_batches 
                SET quantity = 0
                WHERE batch_id = min_expiry_batch_id;
			ELSE
				SET remaining_qty = 0;
                UPDATE inventory_batches
                SET quantity = available_qty - remaining_qty
                WHERE batch_id = min_expiry_batch_id;
                
			END IF;
            
		END WHILE loop_;
        
	ELSEIF NOW.transaction_type = 'IN' THEN
		UPDATE inventory_items
        SET current_stock = current_stock + NEW.quantity
        WHERE item_id = NEW.item_id;
        
        SET batch_id_ = NEW_BATCH_ID();
        
    
		

END |

DELIMITER ;
