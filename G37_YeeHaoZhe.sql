/*
Format: G999_MemberName.sql

INDIVIDUAL ASSIGNMENT SUBMISSION

STUDENT NAME : YEE HAO ZHE
STUDENT ID : 2205744
GROUP NUMBER : G37
PROGRAMME : CS
Submission date and time: 29-Apr-25

SQL script to be submtted by each member, click save as "G999_MemberName.sql" e.g. G001_SmithWhite.sql

*/

/* Query 1 */

SELECT 
m.MemID, m.MemTierID, 
mt.TierName, 
p.TotalPointsEarned
FROM Membership m
JOIN MembershipTier mt ON m.MemTierID = mt.MemTierID
JOIN Point p ON m.MemID = p.MemID
ORDER BY p.TotalPointsEarned;


/* Query 2 */

SELECT 
v.VoucherCode, v.Value, 
mb.BenefitName
FROM Voucher v
JOIN MembershipBenefit mb ON v.BenefitID = mb.BenefitID
WHERE v.Value > 30;


/* Stored procedure 1 */

CREATE OR REPLACE PROCEDURE UpdateMembershipStatus(
	p_MemID IN Membership.MemID%TYPE,
	p_NewStatus IN Membership.Status%TYPE
) 
IS
BEGIN
	IF p_NewStatus NOT IN ('Active', 'Inactive') THEN
		DBMS_OUTPUT.PUT_LINE('Error: Invalid status provided. Use ''Active'' or ''Inactive''.');
		RETURN;
	END IF;

	UPDATE Membership
	SET Status = p_NewStatus
	WHERE MemID = p_MemID;

	IF SQL%NOTFOUND THEN
		DBMS_OUTPUT.PUT_LINE('Warning: Member ID ' || p_MemID || ' not found. No status updated.');
	ELSE
		DBMS_OUTPUT.PUT_LINE('Success: Status for Member ID ' || p_MemID || ' updated to ' || p_NewStatus || '.');
		COMMIT;
	END IF;
END;
/

--Executing
SET SERVEROUTPUT ON;
EXECUTE UpdateMembershipStatus('M0002', 'Active');

--To Check
SELECT * FROM membership;


/* Stored procedure 2 */

CREATE OR REPLACE PROCEDURE ViewPromotionDetails(
	p_PromoCode IN Promotion.PromoCode%TYPE
) 
IS
	v_Discount Promotion.DiscountPercentage%TYPE;
	v_ApplicableProducts Promotion.ApplicableProducts%TYPE;
BEGIN
	SELECT DiscountPercentage, ApplicableProducts
	INTO v_Discount, v_ApplicableProducts
	FROM Promotion
	WHERE PromoCode = p_PromoCode;

	DBMS_OUTPUT.PUT_LINE('Promo Code: ' || p_PromoCode);
	DBMS_OUTPUT.PUT_LINE('Discount Percentage: ' || v_Discount || '%');
	DBMS_OUTPUT.PUT_LINE('Applicable Products: ' || v_ApplicableProducts);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Promotion not found for promo code: ' || p_PromoCode);
END;
/

--Executing
SET SERVEROUTPUT ON;
EXECUTE ViewPromotionDetails('APP5');

--To Check
SELECT * FROM promotion;

/* Function 1 */

CREATE OR REPLACE FUNCTION GetMemberTier(
	p_MemID IN Membership.MemID%TYPE
) RETURN VARCHAR2 
IS
	v_TierName MembershipTier.TierName%TYPE;
BEGIN
	SELECT mt.TierName
	INTO v_TierName
	FROM Membership m
	JOIN MembershipTier mt ON m.MemTierID = mt.MemTierID
	WHERE m.MemID = p_MemID;
    
	RETURN v_TierName;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'Not Found';
END;
/

--Executing

SET SERVEROUTPUT ON;
DECLARE
    v_tier VARCHAR2(20);
BEGIN
    v_tier := GetMemberTier('M0001');
    DBMS_OUTPUT.PUT_LINE('Tier for M0001: ' || v_tier);
END;
/


/* Function 2 */

CREATE OR REPLACE FUNCTION Get_Tier_Benefit_Names (
	p_MemTierID IN MembershipTier.MemTierID%TYPE
) RETURN VARCHAR2 
IS
	v_benefit_list VARCHAR2(4000) := NULL;
	v_benefit_name MembershipBenefit.BenefitName%TYPE;
	CURSOR benefit_cursor IS
		SELECT BenefitName
		FROM MembershipBenefit
		WHERE MemTierID = p_MemTierID
		ORDER BY BenefitName; 

BEGIN
	OPEN benefit_cursor;
	LOOP
		FETCH benefit_cursor INTO v_benefit_name;
		EXIT WHEN benefit_cursor%NOTFOUND;

		IF v_benefit_list IS NOT NULL THEN
			v_benefit_list := v_benefit_list || ', ';
		END IF;

		IF LENGTH(v_benefit_list || v_benefit_name) < 4000 THEN
			v_benefit_list := v_benefit_list || v_benefit_name;
		ELSE
			v_benefit_list := v_benefit_list || '...';
		EXIT;
		END IF;
	END LOOP;
	CLOSE benefit_cursor;

	IF v_benefit_list IS NULL THEN
		RETURN 'No benefits found';
	ELSE
		RETURN v_benefit_list;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF benefit_cursor%ISOPEN THEN
			CLOSE benefit_cursor;
		END IF;
		RETURN 'Error retrieving benefits: ' || SQLERRM;
END;
/

--Executing

SET SERVEROUTPUT ON;
DECLARE
	v_benefits VARCHAR2(4000);
	v_tier_id MembershipTier.MemTierID%TYPE := 'L02';
BEGIN
	v_benefits := Get_Tier_Benefit_Names(v_tier_id);
	DBMS_OUTPUT.PUT_LINE('Benefit names for Tier ' || v_tier_id || ': ' || v_benefits);
END;
/
