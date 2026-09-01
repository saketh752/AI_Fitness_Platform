CREATE TABLE recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    status VARCHAR(255) NOT NULL,
    risk_level VARCHAR(255) NULL,
    plan_name VARCHAR(255) NULL,
    weeks INT NULL DEFAULT 12,
    days_per_week INT NULL,
    minutes_per_session INT NULL,
    nutrition_target VARCHAR(255) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_recommendations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE recommendation_exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recommendation_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,
    day_number INT NULL,
    order_index INT NULL,
    sets INT NULL,
    reps VARCHAR(255) NULL,
    CONSTRAINT fk_recommendation_exercises_rec FOREIGN KEY (recommendation_id) REFERENCES recommendations(id) ON DELETE CASCADE,
    CONSTRAINT fk_recommendation_exercises_ex FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

