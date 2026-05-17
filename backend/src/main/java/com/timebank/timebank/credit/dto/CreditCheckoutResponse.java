package com.timebank.timebank.credit.dto;

public class CreditCheckoutResponse {

    private String sessionId;
    private String packageId;
    private int displayHours;
    private int amountTry;
    private int totalMinutes;
    private String provider;
    private boolean demoMode;
    /** Harici ödeme (iyzico / Stripe vb.) için yönlendirme URL'si; demo modda null */
    private String checkoutUrl;

    public CreditCheckoutResponse() {
    }

    public CreditCheckoutResponse(
            String sessionId,
            String packageId,
            int displayHours,
            int amountTry,
            int totalMinutes,
            String provider,
            boolean demoMode,
            String checkoutUrl
    ) {
        this.sessionId = sessionId;
        this.packageId = packageId;
        this.displayHours = displayHours;
        this.amountTry = amountTry;
        this.totalMinutes = totalMinutes;
        this.provider = provider;
        this.demoMode = demoMode;
        this.checkoutUrl = checkoutUrl;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getPackageId() {
        return packageId;
    }

    public void setPackageId(String packageId) {
        this.packageId = packageId;
    }

    public int getDisplayHours() {
        return displayHours;
    }

    public void setDisplayHours(int displayHours) {
        this.displayHours = displayHours;
    }

    public int getAmountTry() {
        return amountTry;
    }

    public void setAmountTry(int amountTry) {
        this.amountTry = amountTry;
    }

    public int getTotalMinutes() {
        return totalMinutes;
    }

    public void setTotalMinutes(int totalMinutes) {
        this.totalMinutes = totalMinutes;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public boolean isDemoMode() {
        return demoMode;
    }

    public void setDemoMode(boolean demoMode) {
        this.demoMode = demoMode;
    }

    public String getCheckoutUrl() {
        return checkoutUrl;
    }

    public void setCheckoutUrl(String checkoutUrl) {
        this.checkoutUrl = checkoutUrl;
    }
}
