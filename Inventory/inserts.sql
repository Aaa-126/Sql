INSERT INTO inventory_items (item_id, item_name, category, current_stock, unit, price,avg_daily_usage) VALUES
(1, 'Bath Towel', 'Linen', 200, 'pcs', 150,20),
(2, 'Shampoo Bottle', 'Toiletries', 500, 'bottles', 400,50),
(3, 'Toilet Paper Roll', 'Toiletries', 1000, 'rolls', 100,100),
(4, 'Bedsheet', 'Linen', 150, 'pcs', 500,15),
(5, 'Room Freshener', 'Cleaning', 300, 'cans', 300, 10);

INSERT INTO reorder_rules (item_id, reorder_quantity, safety_stock, min_required, max_stock_level, review_frequency_days, last_review_date) VALUES
(1, 140, 60, 40, 600, 14, '2025-06-01'),
(2, 350, 150, 100, 1500, 14, '2025-06-01'),
(3, 700, 300, 200, 3000, 14, '2025-06-01'),
(4, 105, 45, 30, 450, 14, '2025-06-01'),
(5, 70, 30, 20, 300, 14, '2025-06-01');
INSERT INTO suppliers (supplier_id, supplier_name, contact_person, phone, email, address, rating) VALUES
(1, 'Fresh Linen Co.', 'Alice', '1234567890', 'alice@linen.com', 'New Delhi', 4),
(2, 'CleanWell Supplies', 'Bob', '9876543210', 'bob@cleanwell.com', 'Mumbai', 5);
INSERT INTO supplier_items (supplier_id, item_id, lead_time_days) VALUES
(1, 1, 7),
(2, 2, 4),
(2, 3, 3),
(1, 4, 4),
(1, 5, 2);

INSERT INTO guests (guest_name, room_no, phone, email) VALUES
('John Smith', 101, '9876543210', 'john.smith@example.com'),
('Aisha Khan', 102, '9123456789', 'aisha.khan@example.com'),
('Li Wei', 103, '9988776655', 'li.wei@example.com'),
('Carlos Fernandez', 104, '8899001122', 'carlos.fernandez@example.com'),
('Sara Patel', 105, '9001122334', 'sara.patel@example.com');



INSERT INTO stock_transaction (transaction_id, item_id, batch_id, transaction_type, quantity, transaction_date, party_id, expiry_date, is_valid, message) VALUES
(1, 1, NULL, 'IN', 56, '2025-05-13 00:00:00', 1, 2025, 1, 'successful');

INSERT INTO stock_transaction (transaction_id, item_id, transaction_type, quantity, transaction_date, party_id, expiry_date, is_valid, message) VALUES
(2, 1,'OUT', 13, '2025-05-23 00:00:00', NULL, 2025, 1, 'successful');

