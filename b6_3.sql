CREATE DATABASE b6_3;
USE b6_3;

-- Tạo bảng users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    myMoney DOUBLE NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(11),
    dateOfBirth DATE,
    status BIT
);

-- Tạo bảng transfer
CREATE TABLE transfer (
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    money DOUBLE NOT NULL,
    transfer_date DATETIME NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);
DELIMITER //

CREATE PROCEDURE transfer_money (
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_money DOUBLE
)
BEGIN
    DECLARE sender_balance DOUBLE;

    -- Bắt đầu transaction
    START TRANSACTION;

    -- Kiểm tra số dư của người gửi
    SELECT myMoney INTO sender_balance
    FROM users
    WHERE id = p_sender_id
    FOR UPDATE;

    -- Kiểm tra nếu số tiền gửi vượt quá số dư, rollback transaction
    IF sender_balance >= p_money THEN
        -- Trừ tiền người gửi
        UPDATE users
        SET myMoney = myMoney - p_money
        WHERE id = p_sender_id;

        -- Cộng tiền cho người nhận
        UPDATE users
        SET myMoney = myMoney + p_money
        WHERE id = p_receiver_id;

        -- Ghi thông tin vào bảng transfer
        INSERT INTO transfer (sender_id, receiver_id, money, transfer_date)
        VALUES (p_sender_id, p_receiver_id, p_money, NOW());

        -- Commit transaction
        COMMIT;
    ELSE
        -- Nếu không đủ tiền, rollback
        ROLLBACK;
        SELECT 'Không đủ tiền để thực hiện giao dịch' AS message;
    END IF;
END //

DELIMITER ;
