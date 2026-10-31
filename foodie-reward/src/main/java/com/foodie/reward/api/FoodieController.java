package com.foodie.reward.api;

import com.foodie.reward.service.FoodieOperations;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class FoodieController {

    private final FoodieOperations service;

    public FoodieController(FoodieOperations service) {
        this.service = service;
    }

    @GetMapping("/state")
    public ApplicationState state() {
        return service.getState();
    }

    @PostMapping("/members/{customerId}/earn")
    public OperationResponse earnPoints(
            @PathVariable int customerId,
            @Valid @RequestBody AmountRequest request) {
        return service.earnPoints(customerId, request.amount());
    }

    @PatchMapping("/memberships/{membershipId}")
    public OperationResponse updateMembership(
            @PathVariable String membershipId,
            @Valid @RequestBody StatusRequest request) {
        return service.updateMembershipStatus(membershipId, request.status());
    }

    @PostMapping("/rewards/{rewardId}/redeem")
    public OperationResponse redeem(
            @PathVariable String rewardId,
            @Valid @RequestBody CustomerRequest request) {
        return service.redeemReward(request.customerId(), rewardId);
    }

    @PostMapping("/rewards/{rewardId}/restock")
    public OperationResponse restock(
            @PathVariable String rewardId,
            @Valid @RequestBody QuantityRequest request) {
        return service.restockReward(rewardId, request.quantity());
    }

    @PatchMapping("/redemptions/{redemptionId}")
    public OperationResponse processRedemption(
            @PathVariable String redemptionId,
            @Valid @RequestBody StatusRequest request) {
        return service.processRedemption(redemptionId, request.status());
    }

    @PatchMapping("/transactions/{transactionId}/complete")
    public OperationResponse completeTransaction(@PathVariable String transactionId) {
        return service.completeTransaction(transactionId);
    }

    @DeleteMapping("/transactions/failed")
    public OperationResponse deleteFailedTransactions() {
        return service.deleteFailedTransactions();
    }

    public record AmountRequest(@NotNull @DecimalMin("1.00") BigDecimal amount) {
    }

    public record CustomerRequest(@Positive int customerId) {
    }

    public record QuantityRequest(@Positive int quantity) {
    }

    public record StatusRequest(@NotBlank String status) {
    }
}
