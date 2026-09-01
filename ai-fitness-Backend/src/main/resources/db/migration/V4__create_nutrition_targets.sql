CREATE TABLE nutrition_targets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    target_date DATE NULL,
    calories_target INT NULL,
    protein_grams_target INT NULL,
    carbs_grams_target INT NULL,
    fat_grams_target INT NULL,
    calories_consumed INT NULL DEFAULT 0,
    CONSTRAINT fk_nutrition_targets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

