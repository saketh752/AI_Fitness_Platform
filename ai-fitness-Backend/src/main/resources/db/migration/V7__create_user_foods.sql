CREATE TABLE user_foods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    food_code VARCHAR(255) NOT NULL,
    other_food_detail VARCHAR(255) NULL,
    CONSTRAINT fk_user_foods_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

