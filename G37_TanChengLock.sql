/*
Format: G37_TAN CHENG LOCK.sql

INDIVIDUAL ASSIGNMENT SUBMISSION

STUDENT NAME : TAN CHENG LOCK
STUDENT ID : 2205118
GROUP NUMBER : G37
PROGRAMME : CS
Submission date and time: 29-4-2025

SQL script to be submtted by each member, click save as "G999_MemberName.sql" e.g. G001_SmithWhite.sql

*/



/* Query 1 */

SELECT 
t.TransactionID, t.TransactionStatus, th.HistoryID, 
th.TransactionType,
th.PointsEarned,
th.PointsRedeemed
FROM transaction t, transactionHistory th 
WHERE t.transactionID = th.transactionID 
AND t.TransactionType = th.TransactionType
AND t.PointsEarned = th.PointsEarned
AND t.PointsRedeemed = th.PointsRedeemed
AND t.transactionStatus = 'Completed';



/* Query 2 */

SELECT p.PaymentID, p.TotalAmount, p.PaymentMethod,
t.transactionType, t.pointsEarned, t.transactionStatus
FROM payment p, transaction t
WHERE p.TransactionID = t.TransactionID
AND t.transactionType = 'Earn'
AND t.transactionStatus = 'Completed';



/* Stored procedure 1 */

--Initially
SELECT * FROM transaction WHERE transactionID = 'T0003';

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE Update_TransactionStatus_To_Completed
(p_TransactionID IN VARCHAR2) 
IS
BEGIN
    	-- Update the transaction status to 'Completed'
    	UPDATE Transaction
    	SET TransactionStatus = 'Completed'
    	WHERE TransactionID = p_TransactionID
    	AND TransactionStatus = 'Pending';
    
	DBMS_OUTPUT.PUT_LINE('Transaction ' || p_TransactionID || ' status updated to Completed.');

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	DBMS_OUTPUT.PUT_LINE('Transaction ID ' || p_TransactionID || ' not found or not in Pending status.');
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--Call procedure
EXECUTE Update_TransactionStatus_To_Completed('T0003');

--To check
SELECT * FROM transaction WHERE transactionID = 'T0003';


/* Stored procedure 2 */

--Initially
SELECT * FROM transaction WHERE transactionStatus = 'Failed';

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE Delete_Failed_Transactions IS
   	CURSOR failed_transactions IS
        	SELECT TransactionID, TransactionType
        	FROM Transaction
        	WHERE TransactionStatus = 'Failed';
    	v_payment_id Payment.PaymentID%TYPE;

BEGIN
	FOR txn IN failed_transactions LOOP

        	-- If it is a failed redemption, delete from Redemption table first (child table)
        	IF txn.TransactionType = 'Redeem' THEN
            		DELETE FROM Redemption WHERE TransactionID = txn.TransactionID;
        	END IF;
        
        	-- Find the PaymentID associated with Transaction
        	BEGIN
            		SELECT PaymentID INTO v_payment_id
            		FROM Payment
            		WHERE TransactionID = txn.TransactionID;
            
            		-- Delete from subclasses
            		DELETE FROM Ewallet WHERE PaymentID = v_payment_id;
            		DELETE FROM Card WHERE PaymentID = v_payment_id;
            		DELETE FROM OnlineBanking WHERE PaymentID = v_payment_id;
            
            		-- Delete Payment (superclass)
            		DELETE FROM Payment WHERE PaymentID = v_payment_id;
        	EXCEPTION
            		WHEN NO_DATA_FOUND THEN
                	NULL;
        	END;
        
        	-- Finally, delete the Transaction table (parent table)
        	DELETE FROM Transaction WHERE TransactionID = txn.TransactionID;
        
        	DBMS_OUTPUT.PUT_LINE('Successfully deleted failed transaction: ' || txn.TransactionID);
        
    	END LOOP;

EXCEPTION
    	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--Call procedure
EXECUTE Delete_Failed_Transactions;

--To check
SELECT * FROM transaction WHERE transactionStatus = 'Failed';




/* Function 1 */
CREATE OR REPLACE FUNCTION Get_TransactionStatus
(p_TransactionID IN VARCHAR2) 
RETURN VARCHAR2
IS
	v_status VARCHAR2(20);
BEGIN
    	SELECT TransactionStatus INTO v_status
    	FROM Transaction
   	WHERE TransactionID = p_TransactionID;

    	RETURN v_status;

EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	RETURN 'Transaction not found';
    	WHEN OTHERS THEN
        	RETURN 'Error: ' || SQLERRM;
END;
/


--Call function
SET SERVEROUTPUT ON;

DECLARE
    	v_transactionID VARCHAR2(20) := 'T0001'; 
    	v_status VARCHAR2(20);
BEGIN
    	v_status := Get_TransactionStatus(v_transactionID);
    	DBMS_OUTPUT.PUT_LINE('Transaction Status: ' || v_status);
END;
/


/* Function 2 */
CREATE OR REPLACE FUNCTION Get_Customer_Total_Payment_Amount
(p_CustID IN NUMBER)
RETURN VARCHAR2
IS
    	v_total_transactions NUMBER := 0;
    	v_total_payments NUMBER := 0;
    	v_total_history NUMBER := 0;
    	v_summary VARCHAR2(1000);

BEGIN
    	-- Count total transactions
    	SELECT COUNT(*)
    	INTO v_total_transactions
    	FROM Transaction
    	WHERE CustID = p_CustID;
    
    	SELECT NVL(SUM(p.TotalAmount), 0)
	INTO v_total_payments
	FROM Payment p, Transaction t
	WHERE p.TransactionID = t.TransactionID
	AND t.CustID = p_CustID;
    
    	-- Count transaction history records
    	SELECT COUNT(*)
    	INTO v_total_history
    	FROM TransactionHistory
   	WHERE CustID = p_CustID;
    
    	-- Display message
    	v_summary := 'Customer ' || p_CustID || ': ' || v_total_transactions || ' transaction(s), ' || 'Total Paid: RM' || v_total_payments || ', ' || v_total_history || ' history record(s).';
    
    	RETURN v_summary;

EXCEPTION
    	WHEN OTHERS THEN
        	RETURN 'Error: ' || SQLERRM;
END;
/


--Call function
SET SERVEROUTPUT ON;

DECLARE
    	v_custID NUMBER := 10001;
    	v_summary VARCHAR2(1000);
BEGIN
    	v_summary := Get_Customer_Total_Payment_Amount(v_custID);
    	DBMS_OUTPUT.PUT_LINE(v_summary);
END;
/