
# Hotel Inventory Management System

## Overview

Inventory management is a critical component of any business, whether it's a hotel, restaurant, or retail store. This project implements a robust Inventory Management System using MySQL, designed to efficiently manage stock, ensure accuracy, and support business operations.

The system handles the tracking of inventory items, suppliers, guests, and stock transactions (including IN, OUT, and ADJUSTMENT). It supports precise tracking of cost and selling prices, and maintains batch-level data with expiry dates and total cost.

---

##  Schema Highlights

- WRITTEN in inventory_schema.sql.

### Main Tables

| Table                 | Description                                                    |
|-----------------------|----------------------------------------------------------------|
| `inventory_items`     | Stores item master details like name, unit, and stock info.    |
| `suppliers`           | Contains registered supplier information.                      |
| `guests`              | Contains guest information (for OUT transactions).             |
| `supplier_items`      | Maps suppliers to items they provide.                          |
| `stock_transaction`   | Records all IN/OUT/ADJUSTMENT transactions.                    |
| `inventory_batches`   | Tracks batches with expiry and arrival dates.                  |
| `inventory_actions`   | Logs stock alerts (e.g., below reorder level).                 |
| `inventory_recommend` | Logs stock alerts (e.g., below reorder level).                 |
| `reorder_rules`       | Stores needful detail like review_date, frequency, min_stock.  |

---

## Trigger-Based Logic

- WRITTEN in Triggers.sql.
### 1. `val_update_transaction` (BEFORE INSERT)

- Validates transactions based on:
  - Sufficient stock (`OUT`)
  - Supplier/Guest ID existence
  - Preventing negative stock via `ADJUSTMENT`
- If invalid, sets `is_valid = 0` with a relevant message.
- after validation if `is_valid = 1` it updates relevant tables.
- to update inventory_batches a stored procedure "update_batches()" included in triggers.sql is used. 



---

## Stored Procedures

- WRITTEN in stored_procedures.sql.

| Procedure Name     | Purpose                                                                    |
|--------------------|----------------------------------------------------------------------------|
| `calculate_min_required_based_lead_times()` | as name suggest, to avoid stock out issues.       |
| `update_avg_usg(interval)` | (Planned) For calculating average item usage (future expansion).   |
| `check_review()`   | (Optional) Can be used to manually audit review-worthy conditions.         |
| `chech_expiry()`   | check item already expireed or expiring tomorrow.                          |
| `item_with_no_supplier()` | to get notified which items still have no supply.                   |
| `calculate_min_required_based_last_year()`  | as name suggest                                   |
---

## Views
- WRITTEN in views.sql

| View Name          | Purpose                                                              |
|--------------------|----------------------------------------------------------------------|
| `item_summary`     | to provide all needful information about item                        |
| `supplier_log`     | information about supplies extracting from all stock_transaction.    |
| `consumer_log`     | separate consumer orders transaction                                 |
 

---

## ER Diagram

- INCLUDED in repo with PNG name 'ER_diagram.PNG'


---

## Notes

- inserts.sql and demonstration.sql are files for demostration and testing
- Ensure batch expiry dates are either `NULL` or valid.
- All `OUT` transactions update 'inventory_batches' based on expiry_date in FIFO .
- Triggers maintain consistency, but can be expanded for audit or rollback logic.

---

## Future Enhancements

- Average usage analysis
- Supplier and guest analytics
- more improved version of min_required update
- can define max_stock to optimize holding cost
