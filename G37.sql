/*
-- Group Information
COURSE CODE: UCCD2303
PROGRAMME: CS
GROUP NUMBER: G37
GROUP LEADER NAME AND EMAIL: Owi Wilson, owiwilson123@1utar.my
MEMBER 2 NAME: Ng Wei Jie
MEMBER 3 NAME: Tan Cheng Lock
MEMBER 4 NAME: Yee Hao Zhe
Submission date and time: 29 Apr 2025, 5 pm
*/

--drop table in case there is existing table inside the sql

DROP TABLE MembershipTier CASCADE CONSTRAINTS;
DROP TABLE MembershipBenefit CASCADE CONSTRAINTS;
DROP TABLE Promotion CASCADE CONSTRAINTS;
DROP TABLE Voucher CASCADE CONSTRAINTS;
DROP TABLE FreeGift CASCADE CONSTRAINTS;
DROP TABLE RewardCatalog CASCADE CONSTRAINTS;
DROP TABLE Reward CASCADE CONSTRAINTS;
DROP TABLE Restocking CASCADE CONSTRAINTS;
DROP TABLE Inventory CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Membership CASCADE CONSTRAINTS;
DROP TABLE Point CASCADE CONSTRAINTS;
DROP TABLE PointRecord CASCADE CONSTRAINTS;
DROP TABLE Active CASCADE CONSTRAINTS;
DROP TABLE Expiry CASCADE CONSTRAINTS;
DROP TABLE Transaction CASCADE CONSTRAINTS;
DROP TABLE TransactionHistory CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;
DROP TABLE Ewallet CASCADE CONSTRAINTS;
DROP TABLE Card CASCADE CONSTRAINTS;
DROP TABLE OnlineBanking CASCADE CONSTRAINTS;
DROP TABLE Redemption CASCADE CONSTRAINTS;

--create table for database

CREATE TABLE MembershipTier
(MemTierID VARCHAR2(3) PRIMARY KEY,
TierName VARCHAR2(10) CHECK (TierName IN ('Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond')),
PointsRequired NUMBER(5) DEFAULT 0);


CREATE TABLE Membership
(MemID VARCHAR2(5) PRIMARY KEY,
JoinDate DATE DEFAULT SYSDATE,
Status VARCHAR2(10) CHECK (Status IN ('Active', 'Inactive')),
MemTierID VARCHAR2(3),
CONSTRAINT Membership_MemTierID_fk FOREIGN KEY (MemTierID) REFERENCES MembershipTier(MemTierID));


CREATE TABLE Customer
(CustID NUMBER(5) PRIMARY KEY,
CustName VARCHAR2(20) NOT NULL,
PhoneNum VARCHAR2(11) NOT NULL,
CustEmail VARCHAR2(30) UNIQUE NOT NULL,
MemID VARCHAR2(5),
CONSTRAINT Customer_MemID_fk FOREIGN KEY (MemID) REFERENCES Membership(MemID));


CREATE TABLE Point
(PointID VARCHAR2(5) PRIMARY KEY,
PointsBalance NUMBER(5) DEFAULT 0,
PointStatus VARCHAR2(20) CHECK (PointStatus IN ('Active', 'Expiry')),
TotalPointsEarned NUMBER(5) DEFAULT 0,
TotalPointsUsed NUMBER(5) DEFAULT 0,
CustID NUMBER(5),
MemID VARCHAR(5),
CONSTRAINT Point_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID),
CONSTRAINT Point_MemID_fk FOREIGN KEY (MemID) REFERENCES Membership(MemID));


CREATE TABLE MembershipBenefit
(BenefitID VARCHAR2(4) PRIMARY KEY,
MemTierID VARCHAR2(3),
BenefitName VARCHAR2(50) NOT NULL,
BenefitDesc VARCHAR2(255) NOT NULL,
BenefitType VARCHAR2(10) NOT NULL,
CONSTRAINT MembershipBenefit_MemTierID_fk FOREIGN KEY (MemTierID) REFERENCES MembershipTier(MemTierID));


CREATE TABLE Promotion 
(BenefitID VARCHAR2(4),
PromotionID VARCHAR2(5) PRIMARY KEY,
PromoCode VARCHAR2(15) NOT NULL,
DiscountPercentage NUMBER(3) DEFAULT 0,
ApplicableProducts VARCHAR2(100) NOT NULL,
CONSTRAINT Promotion_BenefitID_fk FOREIGN KEY (BenefitID) REFERENCES MembershipBenefit(BenefitID));


CREATE TABLE Voucher 
(BenefitID VARCHAR2(4),
VoucherID VARCHAR2(5) PRIMARY KEY,
VoucherCode VARCHAR2(15) NOT NULL,
Value NUMBER(5, 2) DEFAULT 0,
RedeemableAt VARCHAR2(50) NOT NULL,
CONSTRAINT Voucher_BenefitID_fk FOREIGN KEY (BenefitID) REFERENCES MembershipBenefit(BenefitID));


CREATE TABLE FreeGift
(BenefitID VARCHAR2(4),
GiftID VARCHAR2(5) PRIMARY KEY,
GiftName VARCHAR2(50) NOT NULL,
EligibilityRule VARCHAR2(100) NOT NULL,
CONSTRAINT FreeGift_BenefitID_fk FOREIGN KEY (BenefitID) REFERENCES MembershipBenefit(BenefitID));


CREATE TABLE RewardCatalog
(CatalogID VARCHAR2(5) PRIMARY KEY,
RewardName VARCHAR2(20) NOT NULL,
Description VARCHAR2(100),
IsActive VARCHAR2(10) CHECK (IsActive IN ('Active', 'Inactive')));


CREATE TABLE Reward
(RewardID VARCHAR2(5) PRIMARY KEY,
RewardName VARCHAR2(30) NOT NULL,
PointsRequired NUMBER(5) NOT NULL,
RewardType VARCHAR2(20),
Stock NUMBER(3) DEFAULT 0 NOT NULL,
CatalogID VARCHAR2(5),
CONSTRAINT Reward_CatalogID_fk FOREIGN KEY (CatalogID) REFERENCES RewardCatalog(CatalogID));

CREATE TABLE Inventory
(InventoryID VARCHAR2(4) PRIMARY KEY,
InventoryBlock VARCHAR2(3),
InventoryCapacity NUMBER NOT NULL);

CREATE TABLE Restocking
(RestockID VARCHAR2(5) PRIMARY KEY,
RewardID VARCHAR2(5),
InventoryID VARCHAR2(4),
RestockingDate DATE DEFAULT SYSDATE,
Quantity NUMBER,
SupplierID VARCHAR2(5) NOT NULL,
CONSTRAINT Restocking_RewardID_fk FOREIGN KEY (RewardID) REFERENCES Reward(RewardID),
CONSTRAINT Restocking_InventoryID_fk FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID));


CREATE TABLE PointRecord
(RecordID VARCHAR2(6) PRIMARY KEY,
PointID VARCHAR2(5),
PointsChanged NUMBER(5) NOT NULL,
ChangedType VARCHAR2(10) CHECK(ChangedType IN ('earned', 'used')),
ChangeDate DATE DEFAULT SYSDATE,
CONSTRAINT PointRecord_PointID_fk FOREIGN KEY (PointID) REFERENCES Point(PointID));


CREATE TABLE Active
(ActivePointID VARCHAR2(6) PRIMARY KEY,
PointID VARCHAR2(5),
ExpiryDate DATE DEFAULT SYSDATE,
IsRedeemable CHAR(1) CHECK (IsRedeemable IN ('Y', 'N')),
CONSTRAINT Active_PointID_fk FOREIGN KEY (PointID) REFERENCES Point(PointID));


CREATE TABLE Expiry
(ExpiryPointID VARCHAR2(6) PRIMARY KEY,
PointID VARCHAR2(5),
DateExpired DATE DEFAULT SYSDATE,
Reason VARCHAR2(50) NOT NULL,
CONSTRAINT Expiry_PointID_fk FOREIGN KEY (PointID) REFERENCES Point(PointID));


CREATE TABLE Transaction
(TransactionID VARCHAR2(5) PRIMARY KEY,
TransactionType VARCHAR2(10) CHECK (TransactionType IN ('Redeem', 'Earn')),
PointsEarned NUMBER(8) DEFAULT 0,
PointsRedeemed NUMBER(8) DEFAULT 0,
TransactionDate DATE DEFAULT SYSDATE,
TransactionStatus VARCHAR2(10) CHECK (TransactionStatus IN ('Pending', 'Failed', 'Completed')),
CustID NUMBER(5),
CONSTRAINT Transaction_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID));


CREATE TABLE TransactionHistory
(HistoryID VARCHAR2(5) PRIMARY KEY,
TransactionType VARCHAR2(10) CHECK (TransactionType IN ('Redeem', 'Earn')),
PointsEarned NUMBER(8) DEFAULT 0,
PointsRedeemed NUMBER(8) DEFAULT 0,
TransactionID VARCHAR2(5),
CustID NUMBER(5),
CONSTRAINT TransactionHistory_TransactionID_fk FOREIGN KEY (TransactionID) REFERENCES Transaction(TransactionID),
CONSTRAINT TransactionHistory_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID));


CREATE TABLE Payment
(PaymentID VARCHAR2(8) PRIMARY KEY,
TotalAmount NUMBER(10, 2) NOT NULL,
PaymentStatus VARCHAR2(10) CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')),
PaymentMethod VARCHAR2(20) CHECK (PaymentMethod IN ('E-Wallet', 'Card', 'Online Banking')),
TransactionID VARCHAR2(5),
CONSTRAINT Payment_TransactionID_fk FOREIGN KEY (TransactionID) REFERENCES Transaction(TransactionID));


CREATE TABLE Ewallet
(PaymentID VARCHAR2(8),
Wallet_ID NUMBER(15) PRIMARY KEY,
Wallet_Application VARCHAR2(10) NOT NULL,
Currency_Type VARCHAR2(10) NOT NULL,
CONSTRAINT Ewallet_PaymentID_fk FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID));


CREATE TABLE Card
(PaymentID VARCHAR2(8),
Card_Number NUMBER(20) PRIMARY KEY,
Card_Holder_Name VARCHAR2(50) NOT NULL,
Card_Type VARCHAR2(10) NOT NULL,
CONSTRAINT Card_PaymentID_fk FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID));


CREATE TABLE OnlineBanking
(PaymentID VARCHAR2(8),
Bank_Acc_Number NUMBER(10) PRIMARY KEY,
Bank_Name VARCHAR2(20) NOT NULL,
CONSTRAINT OnlineBanking_PaymentID_fk FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID));


CREATE TABLE Redemption
(RedemptionID VARCHAR2(5) PRIMARY KEY,
CustID NUMBER(5),
RewardID VARCHAR2(5),
RedemptionDate DATE DEFAULT SYSDATE,
Status VARCHAR2(15) CHECK (Status IN ('Pending', 'Completed', 'Failed')),
TransactionID VARCHAR2(5),
PointsUsed NUMBER(5) NOT NULL,
CONSTRAINT Redemption_CustID_fk FOREIGN KEY (CustID) REFERENCES Customer(CustID),
CONSTRAINT Redemption_RewardID_fk FOREIGN KEY (RewardID) REFERENCES Reward(RewardID),
CONSTRAINT Redemption_TransactionID_fk FOREIGN KEY (TransactionID) REFERENCES Transaction(TransactionID));


--insert data for each table

INSERT INTO MembershipTier VALUES ('L01', 'Bronze', 0);
INSERT INTO MembershipTier VALUES ('L02', 'Silver', 1000);
INSERT INTO MembershipTier VALUES ('L03', 'Gold', 2000);
INSERT INTO MembershipTier VALUES ('L04', 'Platinum', 3000);
INSERT INTO MembershipTier VALUES ('L05', 'Diamond', 5000);


INSERT INTO Membership VALUES ('M0001', TO_DATE('07-07-2021', 'DD-MM-YYYY'), 'Active', 'L03');
INSERT INTO Membership VALUES ('M0002', TO_DATE('11-04-2022', 'DD-MM-YYYY'), 'Inactive', 'L02');
INSERT INTO Membership VALUES ('M0003', TO_DATE('18-09-2022', 'DD-MM-YYYY'), 'Inactive', 'L01');
INSERT INTO Membership  VALUES ('M0004', TO_DATE('01-11-2022', 'DD-MM-YYYY'), 'Active', 'L04');
INSERT INTO Membership VALUES ('M0005', TO_DATE('25-12-2022', 'DD-MM-YYYY'), 'Inactive', 'L02');
INSERT INTO Membership VALUES ('M0006', TO_DATE('15-01-2023', 'DD-MM-YYYY'), 'Active', 'L02');
INSERT INTO Membership VALUES ('M0007', TO_DATE('25-03-2023', 'DD-MM-YYYY'), 'Active', 'L01');
INSERT INTO Membership VALUES ('M0008', TO_DATE('30-06-2023', 'DD-MM-YYYY'), 'Active', 'L01');
INSERT INTO Membership VALUES ('M0009', TO_DATE('01-08-2023', 'DD-MM-YYYY'), 'Active', 'L01');
INSERT INTO Membership VALUES ('M0010', TO_DATE('05-10-2023', 'DD-MM-YYYY'), 'Active', 'L02');
INSERT INTO Membership VALUES ('M0011', TO_DATE('22-01-2024', 'DD-MM-YYYY'), 'Inactive', 'L02');
INSERT INTO Membership VALUES ('M0012', TO_DATE('14-02-2024', 'DD-MM-YYYY'), 'Active', 'L01');
INSERT INTO Membership VALUES ('M0013', TO_DATE('20-05-2024', 'DD-MM-YYYY'), 'Active', 'L03');
INSERT INTO Membership VALUES ('M0014', TO_DATE('10-08-2024', 'DD-MM-YYYY'), 'Active', 'L01');
INSERT INTO Membership VALUES ('M0015', TO_DATE('01-12-2024', 'DD-MM-YYYY'), 'Active', 'L01');


INSERT INTO Customer VALUES (10001, 'Ali Bin Ahmad', '01234567890', 'ali.ahmad@gmail.com', 'M0001');
INSERT INTO Customer VALUES (10002, 'Tan Mei Ling', '01987654321', 'tan.mei@outlook.com','M0002');
INSERT INTO Customer VALUES (10003, 'Ravi Kumar', '01311223344', 'ravi.kumar@yahoo.com', 'M0003');
INSERT INTO Customer VALUES (10004, 'Aisha Zainal', '01455667788', 'aisha.zainal@gmail.com', 'M0004');
INSERT INTO Customer VALUES (10005, 'Lim Kok Leong', '01233445566', 'kokleong.lim@mail.com', 'M0005');
INSERT INTO Customer VALUES (10006, 'Siti Nurhaliza', '01199887766', 'siti.nur@gmail.com', 'M0006');
INSERT INTO Customer VALUES (10007, 'James Wong', '01766778899', 'james.wong@live.com', 'M0007');
INSERT INTO Customer VALUES (10008, 'Aminah Hussein', '01811223344', 'aminah.hussein@ymail.com', 'M0008');
INSERT INTO Customer VALUES (10009, 'Chong Wei', '01055667788', 'chong.wei@gmail.com', 'M0009');
INSERT INTO Customer VALUES (10010, 'Maria Tan', '01912345678', 'maria.tan@hotmail.com', 'M0010');
INSERT INTO Customer VALUES (10011, 'Koo Zhe Quan', '0211209198', 'kooquan@gmail.com', 'M0011');
INSERT INTO Customer VALUES (10012, 'Nur Sabrina', '01266554433', 'sabrina_nur@outlook.com', 'M0012');
INSERT INTO Customer VALUES (10013, 'Lim Jing Yee', '01933221144', 'jingyee.lim@mail.com', 'M0013');
INSERT INTO Customer VALUES (10014, 'Zulkifli Hassan', '01833445566', 'zulkifli.has@gmail.com', 'M0014');
INSERT INTO Customer VALUES (10015, 'Anita Das', '01155667788', 'anita.das@hotmail.com', 'M0015');


INSERT INTO Point VALUES ('P1001', 1500, 'Active', 2500, 1000, 10001, 'M0001');
INSERT INTO Point VALUES ('P1002', 500, 'Active', 1500, 1000, 10002, 'M0002');
INSERT INTO Point VALUES ('P1003', 0, 'Expiry', 500, 500, 10003, 'M0003');
INSERT INTO Point VALUES ('P1004', 2000, 'Active', 3000, 1000, 10004, 'M0004');
INSERT INTO Point VALUES ('P1005', 0, 'Expiry', 1000, 1000, 10005, 'M0005');
INSERT INTO Point VALUES ('P1006', 750, 'Active', 1250, 500, 10006, 'M0006');
INSERT INTO Point VALUES ('P1007', 0, 'Expiry', 750, 750, 10007, 'M0007');
INSERT INTO Point VALUES ('P1008', 300, 'Active', 800, 500, 10008, 'M0008');
INSERT INTO Point VALUES ('P1009', 0, 'Expiry', 300, 300, 10009, 'M0009');
INSERT INTO Point VALUES ('P1010', 1200, 'Active', 1700, 500, 10010, 'M0010');
INSERT INTO Point VALUES ('P1011', 900, 'Active', 1400, 500, 10011, 'M0011');
INSERT INTO Point VALUES ('P1012', 0, 'Expiry', 600, 600, 10012, 'M0012');
INSERT INTO Point VALUES ('P1013', 1800, 'Active', 2300, 500, 10013, 'M0013');
INSERT INTO Point VALUES ('P1014', 400, 'Active', 900, 500, 10014, 'M0014');
INSERT INTO Point VALUES ('P1015', 0, 'Expiry', 400, 400, 10015, 'M0015');


INSERT INTO MembershipBenefit VALUES ('B101', 'L01', '5% App Discount', '5% discount on first App Order.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B102', 'L01', '8% Monday Discount', '8% discount on Mondays (Dine-in only).', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B103', 'L02', '10% Lunch Discount', '10% discount on Weekday Lunch Sets.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B104', 'L02', '10% Takeaway Discount', '10% discount on Takeaway Orders (Min spend RM25).', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B105', 'L02', '12% Combo Discount', '12% discount on Combo Meals.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B106', 'L03', '15% Weekend Discount', '15% discount on Weekends (Dine-in, Min spend RM60).', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B107', 'L03', '20% Dine-in Discount', '20% discount on Total Dine-in Bill (Min spend RM80).', 'Promotion');
INSERT INTO MembershipBenefit  VALUES ('B108', 'L03', '20% Family Set Discount', '20% discount on Family Set Menu.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B109', 'L04', '25% Birthday Discount', '25% discount on Entire Bill during Birthday Month (Unlimited use).', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B110', 'L04', '15% Platinum Discount', 'Flat 15% discount on All Orders, always.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B111', 'L05', '30% Diamond Discount', 'Flat 30% discount on all orders for Diamond members.', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B112', 'L05', '50% Anniversary Discount', '50% off entire bill during anniversary month (once a year).', 'Promotion');
INSERT INTO MembershipBenefit VALUES ('B201', 'L01', 'RM5 Drink Voucher', 'RM5 Off Any Drink voucher.', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B202', 'L01', 'RM5 Cashback Voucher', 'RM5 Cashback voucher for next visit (Min spend RM30).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B203', 'L01', 'RM10 Dine-in Voucher', 'RM10 Off Dine-in voucher (Min spend RM40).', 'Voucher');
INSERT INTO MembershipBenefit  VALUES ('B204', 'L02', 'RM15 In-Store Voucher', 'RM15 Off In-Store voucher (Min spend RM50).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B205', 'L02', 'RM10 Delivery Voucher', 'RM10 Off Delivery Fee voucher.', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B206', 'L02', 'RM15 Birthday Voucher', 'RM15 Birthday Voucher (Redeemable on cakes/desserts). (Birthday month).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B207', 'L03', 'RM20 Online Voucher', 'RM20 Off Online Order voucher (Min spend RM70).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B208', 'L03', 'RM30 Birthday Voucher', 'RM30 Birthday Voucher (Any item, Dine-in). (Birthday month).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B209', 'L03', 'RM25 Dine-in Voucher', 'RM25 Off Dine-in voucher (Min spend RM100).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B210', 'L04', 'RM50 VIP Voucher', 'RM50 Voucher (No min spend, any use). (Issued quarterly).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B211', 'L05', ' RM100 Diamond Voucher', ' RM100 voucher with no minimum spend (issued bi-annually).', 'Voucher');
INSERT INTO MembershipBenefit VALUES ('B212', 'L05', 'RM75 Dining Voucher', 'RM75 off dine-in voucher (Min spend RM150).', 'Voucher');
INSERT INTO MembershipBenefit  VALUES ('B301', 'L01', 'Hot Drink Upgrade', 'Complimentary Coffee/Tea upsize. (Any dine-in visit)', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B302', 'L01', 'Keychain Souvenir', 'Collectable Bronze Tier keychain. (Awarded after 3 visits)', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B303', 'L02', 'Free Dessert', 'Choice of standard dessert with any main course purchase.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B304', 'L02', 'Birthday Cake Slice', 'Complimentary slice of cake during birthday week.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B305', 'L02', 'Loyalty Cup', 'Silver Tier branded reusable cup. (Welcome gift upon reaching Silver)', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B306', 'L03', 'Signature Drink', 'Complimentary Signature Drink per visit.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B307', 'L03', 'Exclusive Mug', 'Gold Tier Member exclusive mug. (Welcome gift upon reaching Gold)', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B308', 'L04', 'Free Kids Meal', 'Complimentary Kids Meal with any adult main course purchase.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B309', 'L04', 'VIP Dining Badge', 'Personalised Platinum Tier badge.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B310', 'L04', 'Priority Booking', 'Guaranteed table/priority seating reservations.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B311', 'L05', 'Complimentary Full Meal', 'One complimentary full meal set per quarter.', 'Free Gift');
INSERT INTO MembershipBenefit VALUES ('B312', 'L05', 'Premium Welcome Kit', 'Exclusive Diamond tier welcome kit upon reaching the tier.', 'Free Gift');


INSERT INTO Promotion VALUES ('B101', 'PN001', 'APP5', 5, 'First app order');
INSERT INTO Promotion VALUES ('B102', 'PN002', 'MONDAY8', 8, 'All Monday dine-in orders');
INSERT INTO Promotion VALUES ('B103', 'PN003', 'Lunch10', 10, 'Weekday lunch');
INSERT INTO Promotion VALUES ('B104', 'PN004', 'TAKEOUT10', 10, 'Takeaway Orders');
INSERT INTO Promotion VALUES ('B105', 'PN005', 'COMBO12', 12, 'Combo meals');
INSERT INTO Promotion VALUES ('B106', 'PN006', 'WEEKEND15', 15, 'Weekend dine-in order only');
INSERT INTO Promotion VALUES ('B107', 'PN007', 'DINE20', 20, 'Dine-in only');
INSERT INTO Promotion VALUES ('B108', 'PN008', 'FAMILY20', 20, 'Family set only');
INSERT INTO Promotion VALUES ('B109', 'PN009', 'BDAY25', 25, 'Birthday month only');
INSERT INTO Promotion VALUES ('B110', 'PN010', 'PLATINUM15', 15, 'All orders');
INSERT INTO Promotion VALUES ('B111', 'PN011', 'DIAMOND30', 30, 'All orders');
INSERT INTO Promotion VALUES ('B112', 'PN012', 'ANNIVERSARY50', 50, 'Entire bill');


INSERT INTO Voucher VALUES ('B201', 'VR001', 'DRINKONME', 5, 'Dine-in');
INSERT INTO Voucher VALUES ('B202', 'VR002', 'CASHBACK5', 5, 'Online delivery');
INSERT INTO Voucher VALUES ('B203', 'VR003', 'TREAT10', 10, 'Dine-in');
INSERT INTO Voucher VALUES ('B204', 'VR004', 'VOUCHER15', 15, 'Dine-in');
INSERT INTO Voucher VALUES ('B205', 'VR005', 'DELIVERY10', 10, 'Online delivery');
INSERT INTO Voucher VALUES ('B206', 'VR006', 'BDAYCAKE', 15, 'Any');
INSERT INTO Voucher VALUES ('B207', 'VR007', 'ONLINE20', 20, 'Online delivery');
INSERT INTO Voucher VALUES ('B208', 'VR008', 'VCH30BIRTH', 30, 'Dine-in');
INSERT INTO Voucher VALUES ('B209', 'VR009', 'DINE25OFF', 25, 'Dine-in');
INSERT INTO Voucher VALUES ('B210', 'VR010', 'VIPRM50', 50, 'Any');
INSERT INTO Voucher VALUES ('B211', 'VR011', 'DIAMOND100', 100, 'Any');
INSERT INTO Voucher VALUES ('B212', 'VR012', 'DINE75OFF', 75, 'Dine-in');


INSERT INTO FreeGift VALUES ('B301', 'GF001', 'Hot Drink Upgrade', 'Any dine-in visit');
INSERT INTO FreeGift VALUES ('B302', 'GF002', 'Keychain Souvenir', 'Awarded after 3 visits');
INSERT INTO FreeGift VALUES ('B303', 'GF003', 'Free Dessert', 'With purchase of any main course');
INSERT INTO FreeGift VALUES ('B304', 'GF004', 'Birthday Cake Slice', 'During birthday week');
INSERT INTO FreeGift VALUES ('B305', 'GF005', 'Loyalty Cup', 'Welcome gift upon reaching Silver');
INSERT INTO FreeGift VALUES ('B306', 'GF006', 'Signature Drink', 'Complementary signature drink per visit');
INSERT INTO FreeGift  VALUES ('B307', 'GF007', 'Exclusive Mug', 'Welcome gift upon reaching Gold');
INSERT INTO FreeGift VALUES ('B308', 'GF008', 'Free Kids Meal', 'With purchase any main course');
INSERT INTO FreeGift VALUES ('B309', 'GF009', 'VIP Dining Badge', 'Personalised platinum tier badge');
INSERT INTO FreeGift VALUES ('B310', 'GF010', 'Priority Booking', 'Priority seating reservation');
INSERT INTO FreeGift VALUES ('B311', 'GF011', 'Complimentary Full Meal', 'One per quarter');
INSERT INTO FreeGift VALUES ('B312', 'GF012', 'Premium Welcome Kit', 'Welcome gift upon reaching Diamond tier');


INSERT INTO RewardCatalog VALUES ('C1001', 'Combo Meals', 'Meal combos with drinks', 'Active');
INSERT INTO RewardCatalog VALUES ('C1002', 'Gift Items', 'Branded merchandise', 'Inactive');
INSERT INTO RewardCatalog VALUES ('C1003', 'Refreshments', 'Cold  and beverage selections', 'Active');
INSERT INTO RewardCatalog VALUES ('C1004', 'Seasonal Specials', 'Seasonal or limited time offers', 'Active');
INSERT INTO RewardCatalog VALUES ('C1005', 'Kids'' Rewards', 'Toys and items for kids', 'Inactive');


INSERT INTO Reward VALUES ('R0001', 'Chicken Combo Meal', 180, 'Food', 25, 'C1001');
INSERT INTO Reward VALUES ('R0002', 'Coffee Mug', 120, 'Merchandise', 10, 'C1002');
INSERT INTO Reward VALUES ('R0003', 'Ice Cream Sundae', 90, 'Dessert', 20, 'C1001');
INSERT INTO Reward VALUES ('R0004', 'Fries Upgrade', 60, 'Food Add-on', 40, 'C1001');
INSERT INTO Reward VALUES ('R0005', 'Fried Chicken Piece', 70, 'Food Add-on', 50, 'C1001');
INSERT INTO Reward VALUES ('R0006', 'Cheeseburger Set', 150, 'Food', 30, 'C1001');
INSERT INTO Reward VALUES ('R0007', 'Tumbler Bottle', 160, 'Merchandise', 12, 'C1002');
INSERT INTO Reward VALUES ('R0008', 'Plush Toy', 100, 'Merchandise', 5, 'C1002');
INSERT INTO Reward VALUES ('R0009', 'Free americano', 90, 'Beverage', 15, 'C1003');
INSERT INTO Reward VALUES ('R0010', 'Free Ice Latte', 100, 'Beverage', 20, 'C1003');
INSERT INTO Reward VALUES ('R0011', 'Tupperware', 300, 'Merchandise', 10, 'C1005');
INSERT INTO Reward VALUES ('R0012', 'Kids Meal Set', 140, 'Food', 18, 'C1005');
INSERT INTO Reward VALUES ('R0013', 'Festive Hamper', 250, 'Seasonal', 5, 'C1004');
INSERT INTO Reward VALUES ('R0014', 'Free Ice mocha', 120, 'Beverage', 20, 'C1003');
INSERT INTO Reward VALUES ('R0015', 'Limited Edition Toy', 300, 'Collectible', 3, 'C1005');


INSERT INTO Inventory VALUES ('I001', 'BA1', 100);
INSERT INTO Inventory VALUES ('I002', 'BB1', 150);
INSERT INTO Inventory VALUES ('I003', 'BA2', 100);
INSERT INTO Inventory VALUES ('I004', 'BA3', 100);
INSERT INTO Inventory VALUES ('I005', 'BB3', 150);
INSERT INTO Inventory VALUES ('I006', 'BC1', 50);
INSERT INTO Inventory VALUES ('I007', 'BB2', 150);


INSERT INTO Restocking VALUES ('RS001', 'R0001', 'I001', TO_DATE('04-01-2025', 'DD-MM-YYYY'), 20, 'S001');
INSERT INTO Restocking VALUES ('RS002', 'R0006', 'I002', TO_DATE('16-01-2025', 'DD-MM-YYYY'), 20, 'S002');
INSERT INTO Restocking VALUES ('RS003', 'R0005', 'I003', TO_DATE('02-02-2025', 'DD-MM-YYYY'), 30, 'S003');
INSERT INTO Restocking VALUES ('RS004', 'R0008', 'I004', TO_DATE('22-02-2025', 'DD-MM-YYYY'), 30, 'S001');
INSERT INTO Restocking VALUES ('RS005', 'R0015', 'I005', TO_DATE('27-02-2025', 'DD-MM-YYYY'), 3, 'S005');
INSERT INTO Restocking VALUES ('RS006', 'R0013', 'I006', TO_DATE('11-03-2025', 'DD-MM-YYYY'), 5, 'S002');
INSERT INTO Restocking VALUES ('RS007', 'R0014', 'I003', TO_DATE('11-03-2025', 'DD-MM-YYYY'), 10, 'S003');
INSERT INTO Restocking VALUES ('RS008', 'R0003', 'I004', TO_DATE('15-03-2025', 'DD-MM-YYYY'), 5, 'S003');
INSERT INTO Restocking VALUES ('RS009', 'R0010', 'I007', TO_DATE('16-03-2025', 'DD-MM-YYYY'), 10, 'S004');
INSERT INTO Restocking VALUES ('RS010', 'R0011', 'I001', TO_DATE('20-03-2025', 'DD-MM-YYYY'), 5, 'S001');
INSERT INTO Restocking VALUES ('RS011', 'R0004', 'I002', TO_DATE('02-04-2025', 'DD-MM-YYYY'), 30, 'S002');
INSERT INTO Restocking VALUES ('RS012', 'R0002', 'I002', TO_DATE('03-04-2025', 'DD-MM-YYYY'), 5, 'S003');
INSERT INTO Restocking VALUES ('RS013', 'R0007', 'I003', TO_DATE('03-04-2025', 'DD-MM-YYYY'), 5, 'S001');
INSERT INTO Restocking VALUES ('RS014', 'R0009', 'I006', TO_DATE('10-04-2025', 'DD-MM-YYYY'), 10, 'S005');
INSERT INTO Restocking VALUES ('RS015', 'R0012', 'I002', TO_DATE('10-04-2025', 'DD-MM-YYYY'), 10, 'S002');

INSERT INTO PointRecord VALUES ('PR2001', 'P1001', 1000, 'earned', TO_DATE('15/07/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2002', 'P1001', -500, 'used', TO_DATE('10/11/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2003', 'P1001', 1500, 'earned', TO_DATE('20/12/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2004', 'P1002', 1000, 'earned', TO_DATE('03/01/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2005', 'P1002', -500, 'used', TO_DATE('25/04/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2006', 'P1003', 500, 'earned', TO_DATE('09/12/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2007', 'P1003', -500, 'used', TO_DATE('13/12/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2008', 'P1004', 2000, 'earned', TO_DATE('27/08/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2009', 'P1004', -1000, 'used', TO_DATE('10/10/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2010', 'P1005', 1000, 'earned', TO_DATE('04/02/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2011', 'P1005', -1000, 'used', TO_DATE('18/02/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2012', 'P1006', 750, 'earned', TO_DATE('19/03/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2013', 'P1006', -500, 'used', TO_DATE('28/03/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2014', 'P1007', 750, 'earned', TO_DATE('07/06/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2015', 'P1007', -750, 'used', TO_DATE('29/06/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2016', 'P1008', 500, 'earned', TO_DATE('16/01/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2017', 'P1008', 300, 'earned', TO_DATE('18/01/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2018', 'P1008', -500, 'used', TO_DATE('20/01/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2019', 'P1009', 300, 'earned', TO_DATE('05/01/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2020', 'P1009', -300, 'used', TO_DATE('15/01/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2021', 'P1010', 1200, 'earned', TO_DATE('10/02/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2022', 'P1010', -500, 'used', TO_DATE('25/02/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2023', 'P1011', 900, 'earned', TO_DATE('05/03/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2024', 'P1011', -500, 'used', TO_DATE('15/03/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2025', 'P1012', 600, 'earned', TO_DATE('10/01/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2026', 'P1012', -600, 'used', TO_DATE('20/01/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2027', 'P1013', 1800, 'earned', TO_DATE('15/04/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2028', 'P1013', -500, 'used', TO_DATE('25/04/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2029', 'P1014', 400, 'earned', TO_DATE('01/05/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2030', 'P1014', -500, 'used', TO_DATE('10/05/2024', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2031', 'P1015', 400, 'earned', TO_DATE('15/06/2023', 'DD/MM/YYYY'));
INSERT INTO PointRecord VALUES ('PR2032', 'P1015', -400, 'used', TO_DATE('25/06/2023', 'DD/MM/YYYY'));


INSERT INTO Active VALUES ('ACT301', 'P1001', TO_DATE('31/12/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT302', 'P1002', TO_DATE('25/10/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT303', 'P1004', TO_DATE('10/04/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT304', 'P1006', TO_DATE('28/09/2023', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT305', 'P1008', TO_DATE('20/07/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT306', 'P1010', TO_DATE('25/08/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT307', 'P1011', TO_DATE('15/09/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT308', 'P1013', TO_DATE('25/10/2024', 'DD/MM/YYYY'), 'Y');
INSERT INTO Active VALUES ('ACT309', 'P1014', TO_DATE('10/11/2024', 'DD/MM/YYYY'), 'Y');


INSERT INTO Expiry VALUES ('EXP201', 'P1003', TO_DATE('13/12/2023', 'DD/MM/YYYY'), 'expired');
INSERT INTO Expiry VALUES ('EXP202', 'P1005', TO_DATE('18/02/2024', 'DD/MM/YYYY'), 'expired');
INSERT INTO Expiry VALUES ('EXP203', 'P1007', TO_DATE('29/06/2023', 'DD/MM/YYYY'), 'expired');
INSERT INTO Expiry VALUES ('EXP204', 'P1009', TO_DATE('15/01/2023', 'DD/MM/YYYY'), 'expired');
INSERT INTO Expiry VALUES ('EXP205', 'P1012', TO_DATE('20/01/2023', 'DD/MM/YYYY'), 'expired');
INSERT INTO Expiry VALUES ('EXP206', 'P1015', TO_DATE('25/06/2023', 'DD/MM/YYYY'), 'expired');


INSERT INTO Transaction VALUES ('T0001', 'Earn', 100, 0, TO_DATE('11-04-2025', 'DD-MM-YYYY'), 'Completed', 10001);
INSERT INTO Transaction VALUES ('T0002', 'Redeem', 0, 150, TO_DATE('11-04-2025', 'DD-MM-YYYY'), 'Completed', 10002);
INSERT INTO Transaction VALUES ('T0003', 'Earn', 200, 0, TO_DATE('12-04-2025', 'DD-MM-YYYY'), 'Pending', 10003);
INSERT INTO Transaction VALUES ('T0004', 'Earn', 150, 0, TO_DATE('13-04-2025', 'DD-MM-YYYY'), 'Completed', 10004);
INSERT INTO Transaction VALUES ('T0005', 'Redeem', 0, 120, TO_DATE('14-04-2025', 'DD-MM-YYYY'), 'Completed', 10005);
INSERT INTO Transaction VALUES ('T0006', 'Earn', 300, 0, TO_DATE('15-04-2025', 'DD-MM-YYYY'), 'Completed', 10006);
INSERT INTO Transaction VALUES ('T0007', 'Redeem', 0, 100, TO_DATE('16-04-2025', 'DD-MM-YYYY'), 'Completed', 10007);
INSERT INTO Transaction VALUES ('T0008', 'Earn', 180, 0, TO_DATE('17-04-2025', 'DD-MM-YYYY'), 'Completed', 10008);
INSERT INTO Transaction VALUES ('T0009', 'Earn', 250, 0, TO_DATE('17-04-2025', 'DD-MM-YYYY'), 'Pending', 10009);
INSERT INTO Transaction VALUES ('T0010', 'Redeem', 0, 200, TO_DATE('18-04-2025', 'DD-MM-YYYY'), 'Completed', 10010);
INSERT INTO Transaction VALUES ('T0011', 'Earn', 80, 0, TO_DATE('25-04-2025', 'DD-MM-YYYY'), 'Completed', 10011);
INSERT INTO Transaction VALUES ('T0012', 'Redeem', 0, 90, TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Completed', 10012);
INSERT INTO Transaction VALUES ('T0013', 'Redeem', 0, 100, TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Pending', 10013);
INSERT INTO Transaction VALUES ('T0014', 'Redeem', 0, 80, TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Completed', 10014);
INSERT INTO Transaction VALUES ('T0015', 'Earn', 120, 0, TO_DATE('27-04-2025', 'DD-MM-YYYY'), 'Completed', 10015);
INSERT INTO Transaction VALUES ('T0016', 'Redeem', 0, 50, TO_DATE('27-04-2024', 'DD-MM-YYYY'), 'Pending', 10002);
INSERT INTO Transaction VALUES ('T0017', 'Redeem', 0, 250, TO_DATE('27-04-2025', 'DD-MM-YYYY'), 'Pending', 10004);
INSERT INTO Transaction VALUES ('T0018', 'Earn', 90, 0, TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Failed', 10008);
INSERT INTO Transaction VALUES ('T0019', 'Redeem', 0, 70, TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Completed', 10007);
INSERT INTO Transaction VALUES ('T0020', 'Redeem', 0, 120, TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Failed', 10009);
INSERT INTO Transaction VALUES ('T0021', 'Redeem', 0, 130, TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 10007);
INSERT INTO Transaction VALUES ('T0022', 'Earn', 130, 0, TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 10008);
INSERT INTO Transaction VALUES ('T0023', 'Redeem', 0, 110, TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 10009);
INSERT INTO Transaction VALUES ('T0024', 'Redeem', 0, 60, TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 10012);
INSERT INTO Transaction VALUES ('T0025', 'Redeem', 0, 160, TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 10012);
INSERT INTO Transaction VALUES ('T0026', 'Earn', 100, 0, TO_DATE('30-04-2025', 'DD-MM-YYYY'), 'Completed', 10001);
INSERT INTO Transaction VALUES ('T0027', 'Earn', 135, 0, TO_DATE('30-04-2025', 'DD-MM-YYYY'), 'Completed', 10002);
INSERT INTO Transaction VALUES ('T0028', 'Earn', 105, 0, TO_DATE('30-04-2025', 'DD-MM-YYYY'), 'Completed', 10003);
INSERT INTO Transaction VALUES ('T0029', 'Earn', 160, 0, TO_DATE('30-04-2025', 'DD-MM-YYYY'), 'Completed', 10002);
INSERT INTO Transaction VALUES ('T0030', 'Earn', 50, 0, TO_DATE('30-04-2025', 'DD-MM-YYYY'), 'Completed', 10001);


INSERT INTO TransactionHistory VALUES ('H0001', 'Earn', 100, 0, 'T0001', 10001);
INSERT INTO TransactionHistory VALUES ('H0002', 'Redeem', 0, 150, 'T0002', 10002);
INSERT INTO TransactionHistory VALUES ('H0003', 'Earn', 150, 0, 'T0004', 10004);
INSERT INTO TransactionHistory VALUES ('H0004', 'Redeem', 0, 120, 'T0005', 10005);
INSERT INTO TransactionHistory VALUES ('H0005', 'Earn', 300, 0, 'T0006', 10006);
INSERT INTO TransactionHistory VALUES ('H0006', 'Redeem', 0, 100, 'T0007', 10007);
INSERT INTO TransactionHistory VALUES ('H0007', 'Earn', 180, 0, 'T0008', 10008);
INSERT INTO TransactionHistory VALUES ('H0008', 'Redeem', 0, 200, 'T0010', 10010);
INSERT INTO TransactionHistory VALUES ('H0009', 'Earn', 80, 0, 'T0011', 10011);
INSERT INTO TransactionHistory VALUES ('H0010', 'Redeem', 0, 90, 'T0012', 10012);
INSERT INTO TransactionHistory VALUES ('H0011', 'Redeem', 0, 80, 'T0014', 10014);
INSERT INTO TransactionHistory VALUES ('H0012', 'Earn', 120, 0, 'T0015', 10015);
INSERT INTO TransactionHistory VALUES ('H0013', 'Redeem', 0, 70, 'T0019', 10007);
INSERT INTO TransactionHistory VALUES ('H0014', 'Redeem', 0, 130, 'T0021', 10007);
INSERT INTO TransactionHistory VALUES ('H0015', 'Earn', 130, 0, 'T0022', 10008);
INSERT INTO TransactionHistory VALUES ('H0016', 'Redeem', 0, 110, 'T0023', 10009);
INSERT INTO TransactionHistory VALUES ('H0017', 'Redeem', 0, 60, 'T0024', 10012);
INSERT INTO TransactionHistory VALUES ('H0018', 'Redeem', 0, 160, 'T0025', 10012);
INSERT INTO TransactionHistory VALUES ('H0019', 'Earn', 100, 0, 'T0026', 10001);
INSERT INTO TransactionHistory VALUES ('H0020', 'Earn', 135, 0, 'T0027', 10002);
INSERT INTO TransactionHistory VALUES ('H0021', 'Earn', 105, 0, 'T0028', 10003);
INSERT INTO TransactionHistory VALUES ('H0022', 'Earn', 160, 0, 'T0029', 10002);
INSERT INTO TransactionHistory VALUES ('H0023', 'Earn', 50, 0, 'T0030', 10001);


INSERT INTO Payment VALUES ('PAY0001', 100.00, 'Completed', 'E-Wallet', 'T0001');
INSERT INTO Payment VALUES ('PAY0002', 200.00, 'Pending', 'Card', 'T0003');
INSERT INTO Payment VALUES ('PAY0003', 150.00, 'Completed', 'Online Banking', 'T0004');
INSERT INTO Payment VALUES ('PAY0004', 300.00, 'Completed', 'E-Wallet', 'T0006');
INSERT INTO Payment VALUES ('PAY0005', 180.14, 'Completed', 'Card', 'T0008');
INSERT INTO Payment VALUES ('PAY0006', 250.06, 'Pending', 'Online Banking', 'T0009');
INSERT INTO Payment VALUES ('PAY0007', 80.10, 'Completed', 'E-Wallet', 'T0011');
INSERT INTO Payment VALUES ('PAY0008', 120.65, 'Completed', 'Card', 'T0015');
INSERT INTO Payment VALUES ('PAY0009', 90.33, 'Failed', 'E-Wallet', 'T0018');
INSERT INTO Payment VALUES ('PAY0010', 130.00, 'Completed', 'Online Banking', 'T0022');
INSERT INTO Payment VALUES ('PAY0011', 100.20, 'Completed', 'E-Wallet', 'T0026');
INSERT INTO Payment VALUES ('PAY0012', 135.00, 'Completed', 'Card', 'T0027');
INSERT INTO Payment VALUES ('PAY0013', 105.67, 'Completed', 'Online Banking', 'T0028');
INSERT INTO Payment VALUES ('PAY0014', 160.66, 'Completed', 'Card', 'T0029');
INSERT INTO Payment VALUES ('PAY0015', 50.00, 'Completed', 'Online Banking', 'T0030');


INSERT INTO EWALLET VALUES ('PAY0001', 912345678891, 'GrabPay', 'MYR');
INSERT INTO EWALLET VALUES ('PAY0004', 923456789012, 'Touch''n Go', 'MYR');
INSERT INTO EWALLET VALUES ('PAY0007', 934567890123, 'PayPal', 'USD');
INSERT INTO EWALLET VALUES ('PAY0009', 945678901234, 'Boost', 'MYR');
INSERT INTO EWALLET VALUES ('PAY0011', 956789012345, 'Touch''n Go', 'MYR');


INSERT INTO Card VALUES ('PAY0002', 4098765432109871, 'Sarah Lim', 'Credit');
INSERT INTO Card VALUES ('PAY0005', 4987654321098762, 'Nurul Izzati', 'Debit');
INSERT INTO Card VALUES ('PAY0008', 4876543210987653, 'Kavita Rani', 'Credit');
INSERT INTO Card VALUES ('PAY0012', 4765432109876544, 'Nur Sabrina', 'Credit');
INSERT INTO Card VALUES ('PAY0014', 4654321098765435, 'Anita Das', 'Debit');


INSERT INTO OnlineBanking VALUES ('PAY0003', 1234567890, 'Maybank');
INSERT INTO OnlineBanking VALUES ('PAY0006', 2345678901, 'CIMB');
INSERT INTO OnlineBanking VALUES ('PAY0010', 3456789012, 'RHB');
INSERT INTO OnlineBanking VALUES ('PAY0013', 4567890123, 'Public Bank');
INSERT INTO OnlineBanking VALUES ('PAY0015', 5678901234, 'Maybank');


INSERT INTO Redemption VALUES ('RD01', 10002, 'R0001', TO_DATE('11-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0002', 150);
INSERT INTO Redemption VALUES ('RD02', 10004, 'R0002', TO_DATE('13-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0004', 120);
INSERT INTO Redemption VALUES ('RD03', 10007, 'R0004', TO_DATE('16-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0007', 100);
INSERT INTO Redemption VALUES ('RD04', 10009, 'R0006', TO_DATE('18-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0009', 200);
INSERT INTO Redemption VALUES ('RD05', 10012, 'R0008', TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0012', 90);
INSERT INTO Redemption VALUES ('RD06', 10013, 'R0012', TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Pending', 'T0013', 100);
INSERT INTO Redemption VALUES ('RD07', 10014, 'R0007', TO_DATE('26-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0014', 80);
INSERT INTO Redemption VALUES ('RD08', 10002, 'R0011', TO_DATE('27-04-2025', 'DD-MM-YYYY'), 'Pending', 'T0016', 50);
INSERT INTO Redemption VALUES ('RD09', 10004, 'R0013', TO_DATE('27-04-2025', 'DD-MM-YYYY'), 'Pending', 'T0017', 250);
INSERT INTO Redemption VALUES ('RD10', 10007, 'R0010', TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0019', 70);
INSERT INTO Redemption VALUES ('RD11', 10009, 'R0003', TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Failed', 'T0020', 120);
INSERT INTO Redemption VALUES ('RD12', 10007, 'R0015', TO_DATE('28-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0021', 130);
INSERT INTO Redemption VALUES ('RD13', 10009, 'R0014', TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0023', 110);
INSERT INTO Redemption VALUES ('RD14', 10012, 'R0009', TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0024', 60);
INSERT INTO Redemption VALUES ('RD15', 10012, 'R0005', TO_DATE('29-04-2025', 'DD-MM-YYYY'), 'Completed', 'T0025', 160);
