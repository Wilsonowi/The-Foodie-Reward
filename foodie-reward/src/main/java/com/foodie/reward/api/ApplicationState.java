package com.foodie.reward.api;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public record ApplicationState(
        List<CustomerView> customers,
        Map<String, MembershipView> memberships,
        Map<Integer, PointView> points,
        List<RewardView> rewards,
        List<RedemptionView> redemptions,
        List<TransactionView> transactions) {

    public record CustomerView(
            int id,
            String name,
            String phone,
            String email,
            String memId,
            BigDecimal totalPaid,
            int transactionCount) {
    }

    public record MembershipView(String tier, String join, String status) {
    }

    public record PointView(int bal, String status, int earned, int used, String memId) {
    }

    public record RewardView(
            String id,
            String name,
            int pts,
            String type,
            int stock,
            String cat,
            String lastRestock) {
    }

    public record RedemptionView(
            String id,
            int cust,
            String reward,
            String date,
            String status,
            String txn,
            int pts) {
    }

    public record TransactionView(
            String id,
            String type,
            int earned,
            int redeemed,
            String date,
            String status,
            int cust) {
    }
}
