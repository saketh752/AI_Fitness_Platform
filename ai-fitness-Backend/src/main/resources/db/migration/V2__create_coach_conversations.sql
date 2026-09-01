CREATE TABLE coach_conversations (
    id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    response TEXT,
    status VARCHAR(255),
    created_at DATETIME(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_coach_conversations_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_coach_conversations_user
    ON coach_conversations(user_id);
