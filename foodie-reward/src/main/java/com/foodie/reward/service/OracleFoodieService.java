package com.foodie.reward.service;

import com.foodie.reward.api.OperationResponse;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import org.springframework.context.annotation.Profile;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Profile("oracle")
public class OracleFoodieService extends FoodieService {

    public OracleFoodieService(JdbcTemplate jdbc) {
        super(jdbc);
    }

    @Override
    @Transactional
    public OperationResponse earnPoints(int customerId, BigDecimal amount) {
        String message = call("{ call PKG_FOODIE_REWARDS.EARN_POINTS(?, ?, ?) }", statement -> {
            statement.setInt(1, customerId);
            statement.setBigDecimal(2, amount);
            statement.registerOutParameter(3, Types.VARCHAR);
        }, 3);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse updateMembershipStatus(String membershipId, String status) {
        String message = call("{ call PKG_FOODIE_REWARDS.UPDATE_MEMBERSHIP_STATUS(?, ?, ?) }", statement -> {
            statement.setString(1, membershipId);
            statement.setString(2, status);
            statement.registerOutParameter(3, Types.VARCHAR);
        }, 3);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse redeemReward(int customerId, String rewardId) {
        String message = call("{ call PKG_FOODIE_REWARDS.REDEEM_REWARD(?, ?, ?) }", statement -> {
            statement.setInt(1, customerId);
            statement.setString(2, rewardId);
            statement.registerOutParameter(3, Types.VARCHAR);
        }, 3);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse restockReward(String rewardId, int quantity) {
        String message = call("{ call PKG_FOODIE_REWARDS.RESTOCK_REWARD(?, ?, ?) }", statement -> {
            statement.setString(1, rewardId);
            statement.setInt(2, quantity);
            statement.registerOutParameter(3, Types.VARCHAR);
        }, 3);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse processRedemption(String redemptionId, String outcome) {
        String message = call("{ call PKG_FOODIE_REWARDS.PROCESS_REDEMPTION(?, ?, ?) }", statement -> {
            statement.setString(1, redemptionId);
            statement.setString(2, outcome);
            statement.registerOutParameter(3, Types.VARCHAR);
        }, 3);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse completeTransaction(String transactionId) {
        String message = call("{ call PKG_FOODIE_REWARDS.COMPLETE_TRANSACTION(?, ?) }", statement -> {
            statement.setString(1, transactionId);
            statement.registerOutParameter(2, Types.VARCHAR);
        }, 2);
        return OperationResponse.success(message, getState());
    }

    @Override
    @Transactional
    public OperationResponse deleteFailedTransactions() {
        String message = call("{ call PKG_FOODIE_REWARDS.DELETE_FAILED_TRANSACTIONS(?) }", statement ->
                statement.registerOutParameter(1, Types.VARCHAR), 1);
        return OperationResponse.success(message, getState());
    }

    private String call(String sql, StatementBinder binder, int messageParameter) {
        try {
            return jdbc.execute((Connection connection) -> {
                try (CallableStatement statement = connection.prepareCall(sql)) {
                    binder.bind(statement);
                    statement.execute();
                    return statement.getString(messageParameter);
                }
            });
        } catch (DataAccessException exception) {
            throw new BusinessException(oracleMessage(exception));
        }
    }

    private String oracleMessage(DataAccessException exception) {
        String message = exception.getMostSpecificCause().getMessage();
        if (message == null) {
            return "The Oracle operation could not be completed.";
        }
        int marker = message.indexOf("ORA-20");
        if (marker >= 0) {
            int colon = message.indexOf(':', marker);
            int lineEnd = message.indexOf('\n', colon + 1);
            if (colon >= 0) {
                return message.substring(colon + 1, lineEnd >= 0 ? lineEnd : message.length()).trim();
            }
        }
        return "The Oracle operation could not be completed.";
    }

    @FunctionalInterface
    private interface StatementBinder {
        void bind(CallableStatement statement) throws SQLException;
    }
}
