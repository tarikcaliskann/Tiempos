package com.timebank.timebank.credit.dto;

import jakarta.validation.constraints.NotBlank;

public class CreditCheckoutRequest {

    @NotBlank
    private String packageId;

    public String getPackageId() {
        return packageId;
    }

    public void setPackageId(String packageId) {
        this.packageId = packageId;
    }
}
