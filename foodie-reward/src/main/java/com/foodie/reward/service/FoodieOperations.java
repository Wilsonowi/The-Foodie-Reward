package com.foodie.reward.service;

import com.foodie.reward.api.ApplicationState;
import com.foodie.reward.api.OperationResponse;
import java.math.BigDecimal;

public interface FoodieOperations {

    ApplicationState getState();

    OperationResponse earnPoints(int customerId, BigDecimal amount);

    OperationResponse updateMembershipStatus(String membershipId, String status);

    OperationResponse redeemReward(int customerId, String rewardId);

    OperationResponse restockReward(String rewardId, int quantity);

    OperationResponse processRedemption(String redemptionId, String outcome);

    OperationResponse completeTransaction(String transactionId);

    OperationResponse deleteFailedTransactions();
}
