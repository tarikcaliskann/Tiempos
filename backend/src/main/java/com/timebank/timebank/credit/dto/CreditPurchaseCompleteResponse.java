package com.timebank.timebank.credit.dto;

public class CreditPurchaseCompleteResponse {

    private long timeCreditMinutes;
    private int minutesAdded;
    private int displayHours;
    private int amountTry;

    public CreditPurchaseCompleteResponse() {
    }

    public CreditPurchaseCompleteResponse(
            long timeCreditMinutes,
            int minutesAdded,
            int displayHours,
            int amountTry
    ) {
        this.timeCreditMinutes = timeCreditMinutes;
        this.minutesAdded = minutesAdded;
        this.displayHours = displayHours;
        this.amountTry = amountTry;
    }

    public long getTimeCreditMinutes() {
        return timeCreditMinutes;
    }

    public void setTimeCreditMinutes(long timeCreditMinutes) {
        this.timeCreditMinutes = timeCreditMinutes;
    }

    public int getMinutesAdded() {
        return minutesAdded;
    }

    public void setMinutesAdded(int minutesAdded) {
        this.minutesAdded = minutesAdded;
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
}
