create database s6b1;
use s6b1;
create table if not exists users(
id int primary key auto_increment,
name varchar(100),
address varchar(255),
phone varchar(11),
dateOfBirth date,
status bit
);
create table if not exists products(
id int primary key auto_increment,
name varchar(100),
price double,
stock int,
status bit
);


create table if not exists shopping_cart(
id int primary key auto_increment,
user_id int,
constraint lk_01 foreign key(user_id)  references users(id),
product_id int,
constraint lk_02 foreign key(product_id) references  products(id),
quantity int,
amount double
);

-- OLD và NEW
DELIMITER // 
create trigger trg_product 
after update on products for each row
begin
	update shopping_cart set amount = NEW.price * quantity where product_id = NEW.id;
end //

INSERT INTO users (name, address, phone, dateOfBirth, status) VALUES
('Nguyễn Văn A', 'Hà Nội', '0123456789', '1990-01-01', TRUE),
('Trần Thị B', 'TP. Hồ Chí Minh', '0987654321', '1992-02-02', TRUE),
('Lê Văn C', 'Đà Nẵng', '0876543210', '1988-03-03', TRUE),
('Phạm Thị D', 'Hải Phòng', '0765432109', '1995-04-04', TRUE),
('Ngô Văn E', 'Nha Trang', '0654321098', '1993-05-05', TRUE);

INSERT INTO products (name, price, stock, status) VALUES
('Sản phẩm 1', 100.0, 50, TRUE),
('Sản phẩm 2', 200.0, 30, TRUE),
('Sản phẩm 3', 150.5, 20, TRUE),
('Sản phẩm 4', 300.0, 15, TRUE),
('Sản phẩm 5', 250.75, 40, TRUE);

INSERT INTO shopping_cart (user_id, product_id, quantity, amount) VALUES
(1, 1, 2, 200.0),  -- Nguyễn Văn A mua 2 sản phẩm 1
(2, 2, 1, 200.0),  -- Trần Thị B mua 1 sản phẩm 2
(3, 3, 3, 451.5),  -- Lê Văn C mua 3 sản phẩm 3
(4, 4, 1, 300.0),  -- Phạm Thị D mua 1 sản phẩm 4
(5, 5, 4, 1003.0);  -- Ngô Văn E mua 4 sản phẩm 5

update products set price = 500 where id = 1;
-- Tạo trigger khi xóa product thì những dữ liệu ở bảng
--  shopping_cart có chứa product bị xóa thì cũng phải xóa theo 

DELIMITTER //
create trigger trg_before_insert_shopping_cart
before insert on shopping_cart
for each row
begin 
   declare stock_available int;
   
   select stock into stock_available
   from products
   where id=New.product_id;
 
 IF NEW.quantity > stock_available then
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Số lượng yêu cầu lớn hơn tồn kho!';
    else 
     update products
     Set stock=stock-New.product_id;
     END if;
	END //

DELIMITER ;