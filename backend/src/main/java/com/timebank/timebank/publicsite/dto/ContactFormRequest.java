package com.timebank.timebank.publicsite.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ContactFormRequest {

    @NotBlank
    @Size(max = 120)
    private String name;

    @NotBlank
    @Email
    @Size(max = 254)
    private String email;

    @NotBlank
    @Pattern(regexp = "general|support|billing|partnership|feedback|other")
    private String subject;

    /**
     * Arayüzde görünen konu metni — e-postanın Subject satırı için (ör. yerelleştirilmiş başlık).
     * Boşsa sunucu {@code subject} anahtarından İngilizce etiket üretir.
     */
    @Size(max = 120)
    private String subjectTitle;

    @NotBlank
    @Size(max = 4000)
    private String message;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getSubjectTitle() {
        return subjectTitle;
    }

    public void setSubjectTitle(String subjectTitle) {
        this.subjectTitle = subjectTitle;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
