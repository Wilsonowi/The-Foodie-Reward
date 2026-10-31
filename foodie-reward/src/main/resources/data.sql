MERGE INTO memberships (mem_id, tier_id, join_date, status) KEY (mem_id) VALUES
('M0001','L03','07-07-2021','Active'),
('M0002','L02','11-04-2022','Inactive'),
('M0003','L01','18-09-2022','Inactive'),
('M0004','L04','01-11-2022','Active'),
('M0005','L02','25-12-2022','Inactive'),
('M0006','L02','15-01-2023','Active'),
('M0007','L01','25-03-2023','Active'),
('M0008','L01','30-06-2023','Active'),
('M0009','L01','01-08-2023','Active'),
('M0010','L02','05-10-2023','Active'),
('M0011','L02','22-01-2024','Inactive'),
('M0012','L01','14-02-2024','Active'),
('M0013','L03','20-05-2024','Active'),
('M0014','L01','10-08-2024','Active'),
('M0015','L01','01-12-2024','Active');

MERGE INTO customers
(cust_id, cust_name, phone_num, cust_email, mem_id, total_paid, transaction_count)
KEY (cust_id) VALUES
(10001,'Ali Bin Ahmad','01234567890','ali.ahmad@gmail.com','M0001',250.20,3),
(10002,'Tan Mei Ling','01987654321','tan.mei@outlook.com','M0002',135.00,4),
(10003,'Ravi Kumar','01311223344','ravi.kumar@yahoo.com','M0003',105.67,2),
(10004,'Aisha Zainal','01455667788','aisha.zainal@gmail.com','M0004',150.00,2),
(10005,'Lim Kok Leong','01233445566','kokleong.lim@mail.com','M0005',0.00,1),
(10006,'Siti Nurhaliza','01199887766','siti.nur@gmail.com','M0006',300.00,1),
(10007,'James Wong','01766778899','james.wong@live.com','M0007',0.00,4),
(10008,'Aminah Hussein','01811223344','aminah.hussein@ymail.com','M0008',400.47,4),
(10009,'Chong Wei','01055667788','chong.wei@gmail.com','M0009',250.06,3),
(10010,'Maria Tan','01912345678','maria.tan@hotmail.com','M0010',0.00,1),
(10011,'Koo Zhe Quan','0211209198','kooquan@gmail.com','M0011',80.10,1),
(10012,'Nur Sabrina','01266554433','sabrina_nur@outlook.com','M0012',0.00,3),
(10013,'Lim Jing Yee','01933221144','jingyee.lim@mail.com','M0013',0.00,1),
(10014,'Zulkifli Hassan','01833445566','zulkifli.has@gmail.com','M0014',0.00,1),
(10015,'Anita Das','01155667788','anita.das@hotmail.com','M0015',50.00,1);

MERGE INTO point_accounts
(cust_id, mem_id, points_balance, point_status, total_points_earned, total_points_used)
KEY (cust_id) VALUES
(10001,'M0001',1500,'Active',2500,1000),
(10002,'M0002',500,'Active',1500,1000),
(10003,'M0003',0,'Expiry',500,500),
(10004,'M0004',2000,'Active',3000,1000),
(10005,'M0005',0,'Expiry',1000,1000),
(10006,'M0006',750,'Active',1250,500),
(10007,'M0007',0,'Expiry',750,750),
(10008,'M0008',300,'Active',800,500),
(10009,'M0009',0,'Expiry',300,300),
(10010,'M0010',1200,'Active',1700,500),
(10011,'M0011',900,'Active',1400,500),
(10012,'M0012',0,'Expiry',600,600),
(10013,'M0013',1800,'Active',2300,500),
(10014,'M0014',400,'Active',900,500),
(10015,'M0015',0,'Expiry',400,400);

MERGE INTO reward_catalogs
(catalog_id, catalog_name, catalog_description, is_active) KEY (catalog_id) VALUES
('C1001','Combo Meals','Meal combos with drinks',TRUE),
('C1002','Gift Items','Branded merchandise',FALSE),
('C1003','Refreshments','Cold and hot beverages',TRUE),
('C1004','Seasonal Specials','Limited time offers',TRUE),
('C1005','Kids'' Rewards','Toys and items for kids',FALSE);

MERGE INTO rewards
(reward_id, reward_name, points_required, reward_type, stock, catalog_id, last_restock)
KEY (reward_id) VALUES
('R0001','Chicken Combo Meal',180,'Food',25,'C1001','2025-01-04'),
('R0002','Coffee Mug',120,'Merchandise',10,'C1002','2025-04-03'),
('R0003','Ice Cream Sundae',90,'Dessert',20,'C1001','2025-03-15'),
('R0004','Fries Upgrade',60,'Food Add-on',40,'C1001','2025-04-02'),
('R0005','Fried Chicken Piece',70,'Food Add-on',50,'C1001','2025-02-02'),
('R0006','Cheeseburger Set',150,'Food',30,'C1001','2025-01-16'),
('R0007','Tumbler Bottle',160,'Merchandise',12,'C1002','2025-04-03'),
('R0008','Plush Toy',100,'Merchandise',5,'C1002','2025-02-22'),
('R0009','Free Americano',90,'Beverage',15,'C1003','2025-04-10'),
('R0010','Free Ice Latte',100,'Beverage',20,'C1003','2025-03-16'),
('R0011','Tupperware',300,'Merchandise',10,'C1005','2025-03-20'),
('R0012','Kids Meal Set',140,'Food',18,'C1005','2025-04-10'),
('R0013','Festive Hamper',250,'Seasonal',5,'C1004','2025-03-11'),
('R0014','Free Ice Mocha',120,'Beverage',20,'C1003','2025-03-11'),
('R0015','Limited Edition Toy',300,'Collectible',3,'C1005','2025-02-27');

MERGE INTO reward_transactions
(transaction_id, transaction_type, points_earned, points_redeemed, transaction_date, transaction_status, cust_id)
KEY (transaction_id) VALUES
('T0001','Earn',100,0,'11-04-2025','Completed',10001),
('T0002','Redeem',0,150,'11-04-2025','Completed',10002),
('T0003','Earn',200,0,'12-04-2025','Pending',10003),
('T0004','Earn',150,0,'13-04-2025','Completed',10004),
('T0005','Redeem',0,120,'14-04-2025','Completed',10005),
('T0006','Earn',300,0,'15-04-2025','Completed',10006),
('T0007','Redeem',0,100,'16-04-2025','Completed',10007),
('T0008','Earn',180,0,'17-04-2025','Completed',10008),
('T0009','Earn',250,0,'17-04-2025','Pending',10009),
('T0010','Redeem',0,200,'18-04-2025','Completed',10010),
('T0013','Redeem',0,100,'26-04-2025','Pending',10013),
('T0018','Earn',90,0,'28-04-2025','Failed',10008),
('T0020','Redeem',0,120,'28-04-2025','Failed',10009),
('T0022','Earn',130,0,'29-04-2025','Completed',10008),
('T0026','Earn',100,0,'30-04-2025','Completed',10001),
('T0027','Earn',135,0,'30-04-2025','Completed',10002);

MERGE INTO redemptions
(redemption_id, cust_id, reward_id, redemption_date, status, transaction_id, points_used)
KEY (redemption_id) VALUES
('RD06',10013,'R0012','26-04-2025','Pending','T0013',100),
('RD08',10002,'R0011','27-04-2025','Pending','T0016',50),
('RD09',10004,'R0013','27-04-2025','Pending','T0017',250),
('RD03',10007,'R0004','16-04-2025','Completed','T0007',100),
('RD04',10009,'R0006','18-04-2025','Completed','T0009',200),
('RD11',10009,'R0003','28-04-2025','Failed','T0020',120);
