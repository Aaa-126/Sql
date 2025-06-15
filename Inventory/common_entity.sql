

-- drop table guests;
CREATE TABLE guests(
	guest_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_name VARCHAR(150),
    room_no INT,
    phone VARCHAR(15),
    EMAIL VARCHAR(100)
);