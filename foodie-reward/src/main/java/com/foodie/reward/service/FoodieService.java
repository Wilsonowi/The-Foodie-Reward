package com.foodie.reward.service;

import com.foodie.reward.api.ApplicationState;
import com.foodie.reward.api.ApplicationState.CustomerView;
import com.foodie.reward.api.ApplicationState.MembershipView;
import com.foodie.reward.api.ApplicationState.PointView;
import com.foodie.reward.api.ApplicationState.RedemptionView;
import com.foodie.reward.api.ApplicationState.RewardView;
import com.foodie.reward.api.ApplicationState.TransactionView;
import com.foodie.reward.api.OperationResponse;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Profile("!oracle")
public class FoodieService implements FoodieOperations {

    protected final JdbcTemplate jdbc;

    public FoodieService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public ApplicationState getState() {
        List<CustomerView> customers = jdbc.query("""
                SELECT cust_id, cust_name, phone_num, cust_email, mem_id, total_paid, transaction_count
                FROM customers ORDER BY cust_id
                """, (rs, row) -> new CustomerView(
                rs.getInt("cust_id"), rs.getString("cust_name"), rs.getString("phone_num"),
                rs.getString("cust_email"), rs.getString("mem_id"), rs.getBigDecimal("total_paid"),
                rs.getInt("transaction_count")));

        Map<String, MembershipView> memberships = new LinkedHashMap<>();
        jdbc.query("SELECT mem_id, tier_id, join_date, status FROM memberships ORDER BY mem_id", (RowCallbackHandler) rs ->
                memberships.put(rs.getString("mem_id"), new MembershipView(
                        rs.getString("tier_id"), rs.getString("join_date"), rs.getString("status"))));

        Map<Integer, PointView> points = new LinkedHashMap<>();
        jdbc.query("""
                SELECT cust_id, points_balance, point_status, total_points_earned, total_points_used, mem_id
                FROM point_accounts ORDER BY cust_id
                """, (RowCallbackHandler) rs -> points.put(rs.getInt("cust_id"), new PointView(
                rs.getInt("points_balance"), rs.getString("point_status"),
                rs.getInt("total_points_earned"), rs.getInt("total_points_used"), rs.getString("mem_id"))));

        List<RewardView> rewards = jdbc.query("""
                SELECT reward_id, reward_name, points_required, reward_type, stock, catalog_id, last_restock
                FROM rewards ORDER BY reward_id
                """, (rs, row) -> new RewardView(
                rs.getString("reward_id"), rs.getString("reward_name"), rs.getInt("points_required"),
                rs.getString("reward_type"), rs.getInt("stock"), rs.getString("catalog_id"),
                rs.getString("last_restock")));

        List<RedemptionView> redemptions = jdbc.query("""
                SELECT redemption_id, cust_id, reward_id, redemption_date, status, transaction_id, points_used
                FROM redemptions ORDER BY redemption_id
                """, (rs, row) -> new RedemptionView(
                rs.getString("redemption_id"), rs.getInt("cust_id"), rs.getString("reward_id"),
                rs.getString("redemption_date"), rs.getString("status"), rs.getString("transaction_id"),
                rs.getInt("points_used")));

        List<TransactionView> transactions = jdbc.query("""
                SELECT transaction_id, transaction_type, points_earned, points_redeemed,
                       transaction_date, transaction_status, cust_id
                FROM reward_transactions ORDER BY transaction_id
                """, (rs, row) -> new TransactionView(
                rs.getString("transaction_id"), rs.getString("transaction_type"),
                rs.getInt("points_earned"), rs.getInt("points_redeemed"),
                rs.getString("transaction_date"), rs.getString("transaction_status"), rs.getInt("cust_id")));

        return new ApplicationState(customers, memberships, points, rewards, redemptions, transactions);
    }

    @Transactional
    public OperationResponse earnPoints(int customerId, BigDecimal amount) {
        String status = queryString(
                "SELECT point_status FROM point_accounts WHERE cust_id = ? FOR UPDATE", customerId);
        if (!"Active".equals(status)) {
            throw new BusinessException("No active points account for this customer.");
        }

        int earned = amount.setScale(0, RoundingMode.FLOOR).intValue();
        if (earned < 1) {
            throw new BusinessException("The purchase amount must earn at least one point.");
        }

        jdbc.update("""
                UPDATE point_accounts
                SET points_balance = points_balance + ?, total_points_earned = total_points_earned + ?
                WHERE cust_id = ?
                """, earned, earned, customerId);
        return OperationResponse.success(
                "+" + earned + " points earned from RM" + amount.setScale(2, RoundingMode.HALF_UP) + " spend.",
                getState());
    }

    @Transactional
    public OperationResponse updateMembershipStatus(String membershipId, String status) {
        if (!List.of("Active", "Inactive").contains(status)) {
            throw new BusinessException("Membership status must be Active or Inactive.");
        }
        int changed = jdbc.update("UPDATE memberships SET status = ? WHERE mem_id = ?", status, membershipId);
        requireChanged(changed, "Membership not found.");
        return OperationResponse.success("Membership " + membershipId + " set to " + status + ".", getState());
    }

    @Transactional
    public OperationResponse redeemReward(int customerId, String rewardId) {
        RedemptionCheck check;
        try {
            check = jdbc.queryForObject("""
                    SELECT r.reward_name, r.points_required, r.stock, c.is_active,
                           p.points_balance, p.point_status
                    FROM rewards r
                    JOIN reward_catalogs c ON c.catalog_id = r.catalog_id
                    JOIN point_accounts p ON p.cust_id = ?
                    WHERE r.reward_id = ?
                    FOR UPDATE
                    """, (rs, row) -> new RedemptionCheck(
                    rs.getString("reward_name"), rs.getInt("points_required"), rs.getInt("stock"),
                    rs.getBoolean("is_active"), rs.getInt("points_balance"), rs.getString("point_status")),
                    customerId, rewardId);
        } catch (org.springframework.dao.EmptyResultDataAccessException exception) {
            throw new BusinessException("Customer or reward not found.");
        }

        if (!check.catalogActive()) {
            throw new BusinessException("Reward is inactive. Cannot redeem.");
        }
        if (!"Active".equals(check.pointStatus()) || check.balance() < check.pointsRequired()) {
            throw new BusinessException("Insufficient points to redeem this reward.");
        }
        if (check.stock() <= 0) {
            throw new BusinessException("Reward is out of stock.");
        }

        jdbc.update("UPDATE rewards SET stock = stock - 1 WHERE reward_id = ?", rewardId);
        jdbc.update("""
                UPDATE point_accounts
                SET points_balance = points_balance - ?, total_points_used = total_points_used + ?
                WHERE cust_id = ?
                """, check.pointsRequired(), check.pointsRequired(), customerId);

        return OperationResponse.success(
                "Redemption successful — " + check.rewardName() + " (−" + check.pointsRequired() + " pts).",
                getState());
    }

    @Transactional
    public OperationResponse restockReward(String rewardId, int quantity) {
        int changed = jdbc.update("""
                UPDATE rewards SET stock = stock + ?, last_restock = ? WHERE reward_id = ?
                """, quantity, LocalDate.now().toString(), rewardId);
        requireChanged(changed, "Reward not found.");
        return OperationResponse.success("Restocked +" + quantity + " units.", getState());
    }

    @Transactional
    public OperationResponse processRedemption(String redemptionId, String outcome) {
        if (!List.of("Completed", "Failed").contains(outcome)) {
            throw new BusinessException("Redemption status must be Completed or Failed.");
        }
        int changed = jdbc.update("""
                UPDATE redemptions SET status = ? WHERE redemption_id = ? AND status = 'Pending'
                """, outcome, redemptionId);
        requireChanged(changed, "Pending redemption not found.");
        return OperationResponse.success("Redemption " + redemptionId + " → " + outcome + ".", getState());
    }

    @Transactional
    public OperationResponse completeTransaction(String transactionId) {
        int changed = jdbc.update("""
                UPDATE reward_transactions SET transaction_status = 'Completed'
                WHERE transaction_id = ? AND transaction_status = 'Pending'
                """, transactionId);
        requireChanged(changed, "Pending transaction not found.");
        return OperationResponse.success("Transaction " + transactionId + " marked Completed.", getState());
    }

    @Transactional
    public OperationResponse deleteFailedTransactions() {
        Integer count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM reward_transactions WHERE transaction_status = 'Failed'", Integer.class);
        int failedCount = count == null ? 0 : count;
        if (failedCount == 0) {
            throw new BusinessException("No failed transactions to clean up.");
        }
        jdbc.update("DELETE FROM redemptions WHERE status = 'Failed'");
        jdbc.update("DELETE FROM reward_transactions WHERE transaction_status = 'Failed'");
        return OperationResponse.success(
                "Deleted " + failedCount + " failed transaction(s) and cascaded child rows.", getState());
    }

    private String queryString(String sql, Object... args) {
        try {
            return jdbc.queryForObject(sql, String.class, args);
        } catch (org.springframework.dao.EmptyResultDataAccessException exception) {
            throw new BusinessException("Customer not found.");
        }
    }

    private void requireChanged(int changed, String message) {
        if (changed == 0) {
            throw new BusinessException(message);
        }
    }

    private record RedemptionCheck(
            String rewardName,
            int pointsRequired,
            int stock,
            boolean catalogActive,
            int balance,
            String pointStatus) {
    }
}
