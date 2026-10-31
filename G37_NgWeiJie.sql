/*
Format: G999_MemberName.sql

INDIVIDUAL ASSIGNMENT SUBMISSION

STUDENT NAME : NG WEI JIE
STUDENT ID : 2205566
GROUP NUMBER : G37
PROGRAMME : CS
Submission date and time: 29-APR-25

SQL script to be submtted by each member, click save as "G999_MemberName.sql" e.g. G001_SmithWhite.sql

*/



/* Query 1 */

SELECT c.CustID, c.CustName, mt.TierName, p.TotalPointsEarned
FROM Customer c, Membership m, MembershipTier mt, Point p
WHERE c.MemID = m.MemID
AND m.MemTierID = mt.MemTierID
AND p.CustID = c.CustID
AND m.Status = 'Active'
ORDER BY mt.PointsRequired DESC, p.TotalPointsEarned DESC;


/* Query 2 */

SELECT c.CustName, e.ExpiryPointID, e.DateExpired, e.Reason
FROM Customer c, Point p, Expiry e
WHERE c.CustID = p.CustID
AND p.PointID = e.PointID
ORDER BY e.expiryPointID , e.DateExpired;

/* Stored procedure 1 */

CREATE OR REPLACE PROCEDURE Earn_Points_After_Transaction (
    p_CustID IN NUMBER,
    p_TransactionAmount IN NUMBER
)
IS
    v_EarnedPoints NUMBER;
    v_PointID VARCHAR2(5);
    v_RecordID VARCHAR2(6);
BEGIN
    -- Calculate points earned (1 point per RM1 spent)
    v_EarnedPoints := FLOOR(p_TransactionAmount);

    -- Get PointID for this customer (assume only 1 active point record)
    SELECT PointID
    INTO v_PointID
    FROM Point
    WHERE CustID = p_CustID
    AND PointStatus = 'Active'
    AND ROWNUM = 1;

    -- Generate a new RecordID manually (e.g., 'PR' || random number)
    v_RecordID := 'PR' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,9999)));

    -- Update PointsBalance and TotalPointsEarned
    UPDATE Point
    SET PointsBalance = PointsBalance + v_EarnedPoints,
        TotalPointsEarned = TotalPointsEarned + v_EarnedPoints
    WHERE PointID = v_PointID;

    -- Insert into PointRecord
    INSERT INTO PointRecord (RecordID, PointID, PointsChanged, ChangedType, ChangeDate)
    VALUES (
        v_RecordID,
        v_PointID,
        v_EarnedPoints,
        'earned',
        SYSDATE
    );

    COMMIT;
END;
/


-- Call procedure
EXEC Earn_Points_After_Transaction(10001, 120);

-- Verify updates
SELECT * FROM Point WHERE CustID = 10001;


/* Stored procedure 2 */

CREATE OR REPLACE PROCEDURE Expire_Customer_Points (
    p_CustID IN NUMBER
)
IS
    v_PointID VARCHAR2(5);
    v_ExpiredPoints NUMBER;
    v_RecordID VARCHAR2(6);
BEGIN
    -- Find the active point record for the customer
    SELECT PointID
    INTO v_PointID
    FROM Point
    WHERE CustID = p_CustID
    AND PointStatus = 'Active'
    AND ROWNUM = 1;

    -- Get current PointsBalance
    SELECT PointsBalance
    INTO v_ExpiredPoints
    FROM Point
    WHERE PointID = v_PointID;

    -- Set PointsBalance to 0 and mark as 'Expiry'
    UPDATE Point
    SET PointsBalance = 0,
        TotalPointsUsed = TotalPointsUsed + v_ExpiredPoints,
        PointStatus = 'Expiry'
    WHERE PointID = v_PointID;

    -- Generate new RecordID manually
    v_RecordID := 'PR' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000,9999)));

    -- Insert into PointRecord as "used"
    INSERT INTO PointRecord (RecordID, PointID, PointsChanged, ChangedType, ChangeDate)
    VALUES (
        v_RecordID,
        v_PointID,
        -v_ExpiredPoints,
        'used',
        SYSDATE
    );

    COMMIT;
END;
/

--Call Procedure
EXECUTE Expire_Customer_Points(10002);

--Verify updates
SELECT PointID, CustID, PointsBalance, TotalPointsUsed, PointStatus
FROM Point
WHERE CustID = 10002;



/* Function 1 */

CREATE OR REPLACE FUNCTION Get_Available_Points (
    p_CustID IN NUMBER
) RETURN NUMBER
IS
    v_Points NUMBER;
BEGIN
    SELECT PointsBalance
    INTO v_Points
    FROM Point
    WHERE CustID = p_CustID
    AND PointStatus = 'Active'
    AND ROWNUM = 1;

    RETURN v_Points;
END;
/

--Call function
SET SERVEROUTPUT ON;

DECLARE
    v_custID NUMBER := 10001; -- Can change to test other customers
    v_points NUMBER;
BEGIN
    v_points := Get_Available_Points(v_custID);
    DBMS_OUTPUT.PUT_LINE('Customer ' || v_custID || ' has ' || v_points || ' available points.');
END;
/


/* Function 2 */

CREATE OR REPLACE FUNCTION Predict_Tier_Upgrade(
    p_CustID IN NUMBER
) RETURN VARCHAR2
IS
    v_Points NUMBER;
BEGIN
    SELECT NVL(SUM(PointsBalance), 0)
    INTO v_Points
    FROM Point
    WHERE CustID = p_CustID
      AND PointStatus = 'Active';

    IF v_Points >= 5000 THEN
        RETURN 'Already Top Tier';
    ELSIF v_Points >= 3000 THEN
        RETURN 'Needs ' || (5000 - v_Points) || ' points to Top Tier';
    ELSIF v_Points >= 1000 THEN
        RETURN 'Needs ' || (3000 - v_Points) || ' points to Mid Tier';
    ELSE
        RETURN 'Needs ' || (1000 - v_Points) || ' points to Basic Tier';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR';
END;
/

--Call function
SET SERVEROUTPUT ON;

DECLARE
    v_result VARCHAR2(200);
BEGIN
    v_result := Predict_Tier_Upgrade(10001);
    DBMS_OUTPUT.PUT_LINE('Tier Prediction: ' || v_result);
END;
/
