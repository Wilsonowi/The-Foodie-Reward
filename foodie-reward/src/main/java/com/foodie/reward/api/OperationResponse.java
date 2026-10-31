package com.foodie.reward.api;

public record OperationResponse(String message, String kind, ApplicationState state) {

    public static OperationResponse success(String message, ApplicationState state) {
        return new OperationResponse(message, "ok", state);
    }
}
