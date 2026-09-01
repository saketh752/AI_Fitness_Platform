CREATE TABLE progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    date DATE NULL,
    workouts_completed INT NULL DEFAULT 0,
    calories_burned INT NULL DEFAULT 0,
    active_minutes INT NULL DEFAULT 0,
    streak_days INT NULL DEFAULT 0,
    CONSTRAINT uq_progress_user_date UNIQUE (user_id, date),
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

