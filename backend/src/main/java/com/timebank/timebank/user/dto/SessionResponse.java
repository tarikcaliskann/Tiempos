package com.timebank.timebank.user.dto;

import java.util.UUID;

/** Oturum durumu — JWT gövdede dönmez (HttpOnly çerez veya Authorization header). */
public class SessionResponse {

    private UUID userId;
    private String email;
    private String fullName;
    private String role;

    public SessionResponse(UUID userId, String email, String fullName, String role) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.role = role;
    }

    public UUID getUserId() {
        return userId;
    }

    public String getEmail() {
        return email;
    }

    public String getFullName() {
        return fullName;
    }

    public String getRole() {
        return role;
    }
}
