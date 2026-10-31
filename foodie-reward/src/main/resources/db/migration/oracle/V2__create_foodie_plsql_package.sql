CREATE OR REPLACE PACKAGE pkg_foodie_rewards AS
    PROCEDURE earn_points(
        p_customer_id IN NUMBER,
        p_amount IN NUMBER,
        p_message OUT VARCHAR2
    );

    PROCEDURE update_membership_status(
        p_membership_id IN VARCHAR2,
        p_status IN VARCHAR2,
        p_message OUT VARCHAR2
    );

    PROCEDURE redeem_reward(
        p_customer_id IN NUMBER,
        p_reward_id IN VARCHAR2,
        p_message OUT VARCHAR2
    );

    PROCEDURE restock_reward(
        p_reward_id IN VARCHAR2,
        p_quantity IN NUMBER,
        p_message OUT VARCHAR2
    );

    PROCEDURE process_redemption(
        p_redemption_id IN VARCHAR2,
        p_outcome IN VARCHAR2,
        p_message OUT VARCHAR2
    );

    PROCEDURE complete_transaction(
        p_transaction_id IN VARCHAR2,
        p_message OUT VARCHAR2
    );

    PROCEDURE delete_failed_transactions(
        p_message OUT VARCHAR2
    );
END pkg_foodie_rewards;
/

CREATE OR REPLACE PACKAGE BODY pkg_foodie_rewards AS
    PROCEDURE earn_points(
        p_customer_id IN NUMBER,
        p_amount IN NUMBER,
        p_message OUT VARCHAR2
    ) IS
        v_status point_accounts.point_status%TYPE;
        v_earned NUMBER;
    BEGIN
        IF p_amount IS NULL OR p_amount < 1 THEN
            raise_application_error(-20001, 'Purchase amount must be at least RM1.');
        END IF;

        SELECT point_status
          INTO v_status
          FROM point_accounts
         WHERE cust_id = p_customer_id
           FOR UPDATE;

        IF v_status <> 'Active' THEN
            raise_application_error(-20002, 'No active points account for this customer.');
        END IF;

        v_earned := FLOOR(p_amount);

        UPDATE point_accounts
           SET points_balance = points_balance + v_earned,
               total_points_earned = total_points_earned + v_earned
         WHERE cust_id = p_customer_id;

        p_message := '+' || v_earned || ' points earned from RM'
                     || TO_CHAR(p_amount, 'FM999999990.00') || ' spend.';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20003, 'Customer not found.');
    END earn_points;

    PROCEDURE update_membership_status(
        p_membership_id IN VARCHAR2,
        p_status IN VARCHAR2,
        p_message OUT VARCHAR2
    ) IS
    BEGIN
        IF p_status NOT IN ('Active', 'Inactive') THEN
            raise_application_error(-20004, 'Membership status must be Active or Inactive.');
        END IF;

        UPDATE memberships
           SET status = p_status
         WHERE mem_id = p_membership_id;

        IF SQL%ROWCOUNT = 0 THEN
            raise_application_error(-20005, 'Membership not found.');
        END IF;

        p_message := 'Membership ' || p_membership_id || ' set to ' || p_status || '.';
    END update_membership_status;

    PROCEDURE redeem_reward(
        p_customer_id IN NUMBER,
        p_reward_id IN VARCHAR2,
        p_message OUT VARCHAR2
    ) IS
        v_reward_name rewards.reward_name%TYPE;
        v_points_required rewards.points_required%TYPE;
        v_stock rewards.stock%TYPE;
        v_catalog_active reward_catalogs.is_active%TYPE;
        v_balance point_accounts.points_balance%TYPE;
        v_point_status point_accounts.point_status%TYPE;
    BEGIN
        SELECT r.reward_name, r.points_required, r.stock, c.is_active
          INTO v_reward_name, v_points_required, v_stock, v_catalog_active
          FROM rewards r
          JOIN reward_catalogs c ON c.catalog_id = r.catalog_id
         WHERE r.reward_id = p_reward_id
           FOR UPDATE OF r.stock;

        SELECT points_balance, point_status
          INTO v_balance, v_point_status
          FROM point_accounts
         WHERE cust_id = p_customer_id
           FOR UPDATE;

        IF v_catalog_active <> 1 THEN
            raise_application_error(-20006, 'Reward is inactive. Cannot redeem.');
        ELSIF v_point_status <> 'Active' OR v_balance < v_points_required THEN
            raise_application_error(-20007, 'Insufficient points to redeem this reward.');
        ELSIF v_stock <= 0 THEN
            raise_application_error(-20008, 'Reward is out of stock.');
        END IF;

        UPDATE rewards
           SET stock = stock - 1
         WHERE reward_id = p_reward_id;

        UPDATE point_accounts
           SET points_balance = points_balance - v_points_required,
               total_points_used = total_points_used + v_points_required
         WHERE cust_id = p_customer_id;

        p_message := 'Redemption successful - ' || v_reward_name
                     || ' (-' || v_points_required || ' pts).';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20009, 'Customer or reward not found.');
    END redeem_reward;

    PROCEDURE restock_reward(
        p_reward_id IN VARCHAR2,
        p_quantity IN NUMBER,
        p_message OUT VARCHAR2
    ) IS
    BEGIN
        IF p_quantity IS NULL OR p_quantity <= 0 THEN
            raise_application_error(-20010, 'Restock quantity must be positive.');
        END IF;

        UPDATE rewards
           SET stock = stock + p_quantity,
               last_restock = TO_CHAR(SYSDATE, 'YYYY-MM-DD')
         WHERE reward_id = p_reward_id;

        IF SQL%ROWCOUNT = 0 THEN
            raise_application_error(-20011, 'Reward not found.');
        END IF;

        p_message := 'Restocked +' || p_quantity || ' units.';
    END restock_reward;

    PROCEDURE process_redemption(
        p_redemption_id IN VARCHAR2,
        p_outcome IN VARCHAR2,
        p_message OUT VARCHAR2
    ) IS
    BEGIN
        IF p_outcome NOT IN ('Completed', 'Failed') THEN
            raise_application_error(-20012, 'Redemption status must be Completed or Failed.');
        END IF;

        UPDATE redemptions
           SET status = p_outcome
         WHERE redemption_id = p_redemption_id
           AND status = 'Pending';

        IF SQL%ROWCOUNT = 0 THEN
            raise_application_error(-20013, 'Pending redemption not found.');
        END IF;

        p_message := 'Redemption ' || p_redemption_id || ' -> ' || p_outcome || '.';
    END process_redemption;

    PROCEDURE complete_transaction(
        p_transaction_id IN VARCHAR2,
        p_message OUT VARCHAR2
    ) IS
    BEGIN
        UPDATE reward_transactions
           SET transaction_status = 'Completed'
         WHERE transaction_id = p_transaction_id
           AND transaction_status = 'Pending';

        IF SQL%ROWCOUNT = 0 THEN
            raise_application_error(-20014, 'Pending transaction not found.');
        END IF;

        p_message := 'Transaction ' || p_transaction_id || ' marked Completed.';
    END complete_transaction;

    PROCEDURE delete_failed_transactions(
        p_message OUT VARCHAR2
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_count
          FROM reward_transactions
         WHERE transaction_status = 'Failed';

        IF v_count = 0 THEN
            raise_application_error(-20015, 'No failed transactions to clean up.');
        END IF;

        DELETE FROM redemptions WHERE status = 'Failed';
        DELETE FROM reward_transactions WHERE transaction_status = 'Failed';

        p_message := 'Deleted ' || v_count || ' failed transaction(s) and cascaded child rows.';
    END delete_failed_transactions;
END pkg_foodie_rewards;
/
