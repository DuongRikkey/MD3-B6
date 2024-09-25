CREATE DATABASE b6_2;
USE b6_2;

-- Tạo bảng users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(11),
    dateOfBirth DATE,
    status BIT
);

-- Tạo bảng products
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DOUBLE NOT NULL,
    stock INT NOT NULL,
    status BIT
);

-- Tạo bảng shopping_cart
CREATE TABLE shopping_cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    amount DOUBLE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Tạo procedure để thêm sản phẩm vào giỏ hàng và kiểm tra stock
DELIMITER //

CREATE PROCEDURE add_to_cart (
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_amount DOUBLE
)
BEGIN
    DECLARE current_stock INT;
    
    -- Bắt đầu transaction
    START TRANSACTION;

    -- Kiểm tra stock của sản phẩm
    SELECT stock INTO current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;

    -- Nếu stock đủ, thêm sản phẩm vào giỏ hàng
    IF current_stock >= p_quantity THEN
        -- Cập nhật stock
        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;

        -- Thêm sản phẩm vào giỏ hàng
        INSERT INTO shopping_cart (user_id, product_id, quantity, amount)
        VALUES (p_user_id, p_product_id, p_quantity, p_amount);

        -- Commit transaction
        COMMIT;
    ELSE
        -- Nếu không đủ stock, rollback
        ROLLBACK;
        SELECT 'Stock không đủ';
    END IF;
END //

DELIMITER ;

-- Tạo procedure để xóa sản phẩm khỏi giỏ hàng và trả lại stock
DELIMITER //

CREATE PROCEDURE remove_from_cart (
    IN p_user_id INT,
    IN p_product_id INT
)
BEGIN
    DECLARE cart_quantity INT;

    -- Bắt đầu transaction
    START TRANSACTION;

    -- Lấy số lượng sản phẩm trong giỏ hàng
    SELECT quantity INTO cart_quantity
    FROM shopping_cart
    WHERE user_id = p_user_id AND product_id = p_product_id
    FOR UPDATE;

    -- Cập nhật lại stock
    UPDATE products
    SET stock = stock + cart_quantity
    WHERE id = p_product_id;

    -- Xóa sản phẩm khỏi giỏ hàng
    DELETE FROM shopping_cart
    WHERE user_id = p_user_id AND product_id = p_product_id;

    -- Commit transaction
    COMMIT;
END //

DELIMITER ;


   
