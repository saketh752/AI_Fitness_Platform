package com.aifitness.email;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class EmailService {

    private final ObjectProvider<JavaMailSender> mailSenderProvider;

    @Value("${spring.mail.username:noreply@aifitness.com}")
    private String fromEmail;

    public EmailService(ObjectProvider<JavaMailSender> mailSenderProvider) {
        this.mailSenderProvider = mailSenderProvider;
    }

    public void sendPasswordResetEmail(String toEmail, String resetLink) {
        JavaMailSender mailSender = mailSenderProvider.getIfAvailable();

        log.info("------------------------------------------------------------");
        log.info("PASSWORD RESET LINK for [{}]: {}", toEmail, resetLink);
        log.info("------------------------------------------------------------");

        if (mailSender != null) {
            try {
                SimpleMailMessage message = new SimpleMailMessage();
                message.setFrom(fromEmail);
                message.setTo(toEmail);
                message.setSubject("Reset Your AI Fitness Password");
                message.setText("Hello,\n\n"
                        + "You requested to reset your password for AI Fitness.\n"
                        + "Please use the following link to reset your password:\n\n"
                        + resetLink + "\n\n"
                        + "This link will expire in 30 minutes.\n"
                        + "If you did not make this request, you can safely ignore this email.\n\n"
                        + "Best regards,\nThe AI Fitness Team");

                mailSender.send(message);
                log.info("Successfully dispatched password reset email to: {}", toEmail);
            } catch (Exception e) {
                log.warn("Could not send email via SMTP (using logged link as fallback): {}", e.getMessage());
            }
        } else {
            log.info("JavaMailSender not configured. Reset link logged to console.");
        }
    }
}

