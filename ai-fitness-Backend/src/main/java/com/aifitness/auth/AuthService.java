package com.aifitness.auth;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.aifitness.auth.dto.AuthResponse;
import com.aifitness.auth.dto.ForgotPasswordRequest;
import com.aifitness.auth.dto.LoginRequest;
import com.aifitness.auth.dto.ResetPasswordRequest;
import com.aifitness.auth.dto.SignupRequest;
import com.aifitness.auth.token.PasswordResetToken;
import com.aifitness.auth.token.PasswordResetTokenRepository;
import com.aifitness.config.JwtUtil;
import com.aifitness.email.EmailService;
import com.aifitness.user.User;
import com.aifitness.user.UserProfile;
import com.aifitness.user.UserProfileRepository;
import com.aifitness.user.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    @Value("${app.reset-password-url:http://localhost:8080/reset-password}")
    private String resetPasswordBaseUrl;

    @Transactional
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already in use");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user = userRepository.save(user);

        UserProfile profile = new UserProfile();
        profile.setUser(user);
        profile.setFullName(request.getFullName());
        userProfileRepository.save(profile);

        String token = jwtUtil.generateToken(user.getEmail(), user.getId());

        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .name(profile.getFullName())
                .onboardingComplete(false)
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        UserProfile profile = userProfileRepository.findByUserId(user.getId()).orElse(null);
        String name = profile != null ? profile.getFullName() : "";
        boolean onboardingComplete = profile != null && profile.getDateOfBirth() != null;

        String token = jwtUtil.generateToken(user.getEmail(), user.getId());

        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .name(name)
                .onboardingComplete(onboardingComplete)
                .build();
    }

    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        userRepository.findByEmail(request.getEmail()).ifPresent(user -> {
            // Invalidate any existing unused reset tokens for this user
            passwordResetTokenRepository.deleteByUser(user);

            String token = UUID.randomUUID().toString();
            PasswordResetToken resetToken = PasswordResetToken.builder()
                    .token(token)
                    .user(user)
                    .expiryDate(LocalDateTime.now().plusMinutes(30))
                    .used(false)
                    .build();

            passwordResetTokenRepository.save(resetToken);

            String separator = resetPasswordBaseUrl.contains("?") ? "&" : "?";
            String resetLink = resetPasswordBaseUrl + separator + "token=" + token;

            emailService.sendPasswordResetEmail(user.getEmail(), resetLink);
        });
    }

    public boolean verifyResetToken(String token) {
        if (token == null || token.isBlank()) {
            return false;
        }
        return passwordResetTokenRepository.findByToken(token)
                .filter(t -> !t.isUsed() && !t.isExpired())
                .isPresent();
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired password reset token"));

        if (resetToken.isUsed() || resetToken.isExpired()) {
            throw new IllegalArgumentException("Reset token is invalid or has expired");
        }

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        resetToken.setUsed(true);
        passwordResetTokenRepository.save(resetToken);
        log.info("Password successfully reset for user: {}", user.getEmail());
    }
}
