package com.timebank.timebank.exchange.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class CancelSurveyRequest {

    @NotBlank
    @Pattern(regexp = "SCHEDULE|NOT_NEEDED|OTHER")
    private String reasonCode;

    @Size(max = 500)
    private String note;

    public String getReasonCode() {
        return reasonCode;
    }

    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
