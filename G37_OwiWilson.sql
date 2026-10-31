/*
Format: G999_MemberName.sql

INDIVIDUAL ASSIGNMENT SUBMISSION

STUDENT NAME : OWI WILSON
STUDENT ID : 2206448
GROUP NUMBER : G37
PROGRAMME : CS
Submission date and time: 29-APR-25

SQL script to be submtted by each member, click save as "G999_MemberName.sql" e.g. G001_SmithWhite.sql

*/

/* Query 1 */

SELECT 
    r.RedemptionID,
    c.CustName AS "NAME",
    rw.RewardName,
    r.RedemptionDate AS "DATE",
    r.Status
FROM 
    Redemption r, Customer c, Reward rw
WHERE
    r.CustID = c.CustID AND r.RewardID = rw.RewardID AND r.Status = 'Pending'
ORDER BY 
    r.RedemptionDate ASC;


/* Query 2 */

SELECT 
    rc.CatalogID AS "CID",
    rc.RewardName AS "Catalog",
    r.RewardID AS "RID",
    r.RewardName AS Reward,
    r.PointsRequired
FROM 
    RewardCatalog rc
JOIN 
    Reward r ON rc.CatalogID = r.CatalogID
WHERE 
    rc.IsActive = 'Active'
ORDER BY 
    rc.CatalogID, r.RewardName;


/* Stored procedure 1 */

--Initially To Check
SELECT * FROM Reward;


CREATE OR REPLACE PROCEDURE RedeemRewards (
    cID IN Customer.CustID%TYPE,
    rID IN Reward.RewardID%TYPE
)
IS 
    curPoints Point.PointsBalance%TYPE;
    rewardPoints Reward.PointsRequired%TYPE;
    curStock Reward.Stock%TYPE;
    status RewardCatalog.IsActive%TYPE;
BEGIN
   
    SELECT PointsBalance INTO curPoints
    FROM Point
    WHERE CustID = cID;

    SELECT r.PointsRequired, r.Stock, rc.IsActive
    INTO rewardPoints, curStock, status
    FROM Reward r, RewardCatalog rc
    WHERE r.CatalogID = rc.CatalogID AND r.RewardID = rID;

    IF status != 'Active' THEN
        DBMS_OUTPUT.PUT_LINE('Reward is Inactive. Cannot Redeem.');
    ELSIF curPoints < rewardPoints THEN
        DBMS_OUTPUT.PUT_LINE('Insufficient points to redeem this reward.');
    ELSIF curStock <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Reward is out of stock.');
    ELSE
        
        UPDATE Reward
        SET Stock = Stock - 1
        WHERE RewardID = rID;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Redemption successful.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Customer or Reward not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Fail To Redeem' || SQLERRM);
END;
/

--Executing
EXECUTE RedeemRewards('10001','R0001');

--To Check
SELECT * FROM Reward;


/* Stored procedure 2 */

--Initially To Check
SELECT * FROM Restocking;

CREATE OR REPLACE PROCEDURE RestockRewardItem(
    rID VARCHAR2,
    rewID VARCHAR2,
    invID VARCHAR2,
    qty NUMBER,
    suppID VARCHAR2
)
IS
BEGIN

    UPDATE Reward
    SET Stock = Stock + qty
    WHERE RewardID = rewID;

    INSERT INTO Restocking(RestockID, RewardID, InventoryID, RestockingDate, Quantity, SupplierID) 
    VALUES (rID, rewID, invID, SYSDATE, qty, suppID);

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Failed To Restock' || SQLERRM);
END;
/

--Executing
EXECUTE RestockRewardItem('RS017','R0001','I001',50,'S0001');

--To Check
SELECT * FROM Restocking;



/* Function 1 */

CREATE OR REPLACE FUNCTION CheckStock(
    p_RewardID VARCHAR2
)
RETURN VARCHAR2
IS
    lastRestockDate DATE;
    curStock NUMBER(3);
    str VARCHAR2(100);
BEGIN
    
    SELECT MAX(RestockingDate) INTO lastRestockDate
    FROM Restocking
    WHERE RewardID = p_RewardID;
    
    SELECT Stock INTO curStock
    FROM Reward
    WHERE RewardID = p_RewardID;
    
    IF (SYSDATE - lastRestockDate > 60) AND (curStock <= 10) THEN
        str := 'Low Stock and Overdue Restocking! Need to Restock!';
    ELSIF (SYSDATE - lastRestockDate > 60) THEN
        str := 'Restocking Overdue. Need to Restock!';
    ELSIF (curStock <= 10) THEN
        str := 'Insufficient Stock. Need to Restock!';
    ELSE
        str := 'Sufficient Stock';
    END IF;
    
    RETURN str;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Reward Item Not Found';
    WHEN OTHERS THEN
        RETURN 'Error: Failed To Check Stock';
END;
/

--Call Function
BEGIN
    DBMS_OUTPUT.PUT_LINE(CheckStock('R0001'));
END;
/


/* Function 2 */

CREATE OR REPLACE FUNCTION CanRedeemReward (
    cID IN Customer.CustID%TYPE,
    rID IN Reward.RewardID%TYPE
) RETURN VARCHAR2
IS
    custPoints Point.PointsBalance%TYPE;
    pointsNeeded Reward.PointsRequired%TYPE;
BEGIN

    SELECT PointsBalance INTO custPoints
    FROM Point
    WHERE CustID = cID;

    SELECT PointsRequired INTO pointsNeeded
    FROM Reward
    WHERE RewardID = rID;
    
    IF custPoints >= pointsNeeded THEN
        RETURN 'YES, U CAN REDEEM';
    ELSE
        RETURN 'NO, U CANNOT REDEEM';
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'CUSTOMER DOES NOT EXISTS';
    WHEN OTHERS THEN
        RETURN 'NO, U CANNOT REDEEM';
END;
/

--Call Function
BEGIN
    DBMS_OUTPUT.PUT_LINE(CanRedeemReward(1001, 'R0001'));
END;
/
