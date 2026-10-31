package com.foodie.reward;

import static org.assertj.core.api.Assertions.assertThat;

import com.foodie.reward.api.ApplicationState;
import com.foodie.reward.service.FoodieService;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@Transactional
class FoodieServiceTests {

    @Autowired
    private FoodieService service;

    @Test
    void loadsTheExistingInterfaceData() {
        ApplicationState state = service.getState();

        assertThat(state.customers()).hasSize(15);
        assertThat(state.rewards()).hasSize(15);
        assertThat(state.redemptions()).hasSize(6);
        assertThat(state.transactions()).hasSize(16);
    }

    @Test
    void earnsPointsAndPersistsTheNewBalance() {
        int before = service.getState().points().get(10001).bal();

        service.earnPoints(10001, new BigDecimal("120.80"));

        assertThat(service.getState().points().get(10001).bal()).isEqualTo(before + 120);
    }

    @Test
    void redemptionUpdatesPointsAndStockTogether() {
        ApplicationState before = service.getState();
        int balance = before.points().get(10001).bal();
        int stock = before.rewards().stream().filter(r -> r.id().equals("R0001")).findFirst().orElseThrow().stock();

        service.redeemReward(10001, "R0001");

        ApplicationState after = service.getState();
        assertThat(after.points().get(10001).bal()).isEqualTo(balance - 180);
        assertThat(after.rewards().stream().filter(r -> r.id().equals("R0001")).findFirst().orElseThrow().stock())
                .isEqualTo(stock - 1);
    }
}
