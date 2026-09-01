CREATE TABLE conditions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    default_risk_level VARCHAR(255) NOT NULL,
    active BIT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE condition_aliases (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    condition_id BIGINT NOT NULL,
    alias VARCHAR(255) NOT NULL,
    CONSTRAINT fk_condition_aliases_condition FOREIGN KEY (condition_id) REFERENCES conditions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_conditions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    condition_id BIGINT NOT NULL,
    severity VARCHAR(255),
    recent BIT(1) NOT NULL DEFAULT 0,
    type VARCHAR(255),
    CONSTRAINT fk_user_conditions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_conditions_condition FOREIGN KEY (condition_id) REFERENCES conditions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

