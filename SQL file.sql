CREATE DATABASE ai_fitness_platform
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE ai_fitness_platform;
SELECT DATABASE();
-- ============================================
-- 1. USERS
-- Root table for every application user
-- ============================================

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NULL,

    auth_provider VARCHAR(30) NOT NULL DEFAULT 'LOCAL',
    provider_user_id VARCHAR(255) NULL,

    account_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT chk_users_auth_provider
        CHECK (auth_provider IN ('LOCAL', 'GOOGLE')),

    CONSTRAINT chk_users_account_status
        CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'DELETED'))
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


-- ============================================
-- 2. USER PROFILES
-- One profile for one user
-- ============================================

CREATE TABLE user_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    full_name VARCHAR(100) NULL,
    date_of_birth DATE NULL,
    gender VARCHAR(30) NULL,

    height_cm DECIMAL(5,2) NULL,
    current_weight_kg DECIMAL(5,2) NULL,

    activity_level VARCHAR(30) NULL,
    fitness_experience VARCHAR(30) NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_user_profiles_user_id UNIQUE (user_id),

    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_user_profiles_height
        CHECK (height_cm IS NULL OR height_cm > 0),

    CONSTRAINT chk_user_profiles_weight
        CHECK (current_weight_kg IS NULL OR current_weight_kg > 0)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
SHOW TABLES;
DESCRIBE users;
DESCRIBE user_profiles;
USE ai_fitness_platform;

-- ============================================
-- 3. USER GOALS
-- Stores current and historical fitness goals
-- ============================================

CREATE TABLE user_goals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    goal_type VARCHAR(50) NOT NULL,

    target_weight_kg DECIMAL(5,2) NULL,
    target_date DATE NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    completed_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_user_goals_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_user_goals_type
        CHECK (
            goal_type IN (
                'WEIGHT_GAIN',
                'WEIGHT_LOSS',
                'MUSCLE_GAIN',
                'STRENGTH',
                'GENERAL_FITNESS'
            )
        ),

    CONSTRAINT chk_user_goals_status
        CHECK (
            status IN ('ACTIVE', 'COMPLETED', 'ABANDONED')
        ),

    CONSTRAINT chk_user_goals_target_weight
        CHECK (
            target_weight_kg IS NULL OR target_weight_kg > 0
        )
);

CREATE INDEX idx_user_goals_user_status
ON user_goals(user_id, status);


-- ============================================
-- 4. USER CONSTRAINTS
-- Real-world limitations and preferences
-- ============================================

CREATE TABLE user_constraints (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    constraint_type VARCHAR(50) NOT NULL,
    constraint_value TEXT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_user_constraints_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_user_constraints_type
        CHECK (
            constraint_type IN (
                'FOOD_BUDGET',
                'TRAINING_TIME',
                'HOSTEL_LIMITATION',
                'DIETARY_RESTRICTION',
                'OTHER'
            )
        )
);

CREATE INDEX idx_user_constraints_user_active
ON user_constraints(user_id, is_active);


-- ============================================
-- 5. EQUIPMENT
-- Shared master/reference data
-- ============================================

CREATE TABLE equipment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NULL,
    description TEXT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_equipment_name UNIQUE (name)
);


-- ============================================
-- 6. USER EQUIPMENT
-- Many-to-many: Users <-> Equipment
-- ============================================

CREATE TABLE user_equipment (
    user_id BIGINT NOT NULL,
    equipment_id BIGINT NOT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (user_id, equipment_id),

    CONSTRAINT fk_user_equipment_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_equipment_equipment
        FOREIGN KEY (equipment_id)
        REFERENCES equipment(id)
        ON DELETE RESTRICT
);


-- ============================================
-- 7. FOODS
-- Shared master/reference food data
-- ============================================

CREATE TABLE foods (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(150) NOT NULL,

    serving_size DECIMAL(10,2) NOT NULL,
    serving_unit VARCHAR(30) NOT NULL,

    calories DECIMAL(10,2) NOT NULL DEFAULT 0,
    protein_g DECIMAL(10,2) NOT NULL DEFAULT 0,
    carbs_g DECIMAL(10,2) NOT NULL DEFAULT 0,
    fat_g DECIMAL(10,2) NOT NULL DEFAULT 0,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_food_serving
        UNIQUE (name, serving_size, serving_unit),

    CONSTRAINT chk_food_serving_size
        CHECK (serving_size > 0),

    CONSTRAINT chk_food_calories
        CHECK (calories >= 0),

    CONSTRAINT chk_food_protein
        CHECK (protein_g >= 0),

    CONSTRAINT chk_food_carbs
        CHECK (carbs_g >= 0),

    CONSTRAINT chk_food_fat
        CHECK (fat_g >= 0)
);


-- ============================================
-- 8. USER AVAILABLE FOODS
-- Many-to-many: Users <-> Foods
-- ============================================

CREATE TABLE user_available_foods (
    user_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,

    availability_status VARCHAR(30)
        NOT NULL DEFAULT 'AVAILABLE',

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    PRIMARY KEY (user_id, food_id),

    CONSTRAINT fk_user_available_foods_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_available_foods_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_user_available_food_status
        CHECK (
            availability_status IN (
                'AVAILABLE',
                'LIMITED',
                'UNAVAILABLE'
            )
        )
);
SHOW TABLES;
DESCRIBE user_goals;
DESCRIBE user_constraints;
DESCRIBE equipment;
DESCRIBE foods;
USE ai_fitness_platform;

-- ============================================
-- 9. FITNESS CALCULATIONS
-- Historical snapshots of BMI, BMR, TDEE
-- and nutrition targets
-- ============================================

CREATE TABLE fitness_calculations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    bmi DECIMAL(6,2) NULL,
    bmr DECIMAL(10,2) NULL,
    tdee DECIMAL(10,2) NULL,

    calorie_target DECIMAL(10,2) NULL,
    protein_target_g DECIMAL(10,2) NULL,
    carbs_target_g DECIMAL(10,2) NULL,
    fat_target_g DECIMAL(10,2) NULL,

    calculation_version VARCHAR(30) NOT NULL DEFAULT 'V1',

    calculated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_fitness_calculations_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_fitness_bmi
        CHECK (bmi IS NULL OR bmi > 0),

    CONSTRAINT chk_fitness_bmr
        CHECK (bmr IS NULL OR bmr >= 0),

    CONSTRAINT chk_fitness_tdee
        CHECK (tdee IS NULL OR tdee >= 0),

    CONSTRAINT chk_fitness_calorie_target
        CHECK (calorie_target IS NULL OR calorie_target >= 0),

    CONSTRAINT chk_fitness_protein
        CHECK (protein_target_g IS NULL OR protein_target_g >= 0),

    CONSTRAINT chk_fitness_carbs
        CHECK (carbs_target_g IS NULL OR carbs_target_g >= 0),

    CONSTRAINT chk_fitness_fat
        CHECK (fat_target_g IS NULL OR fat_target_g >= 0)
);

CREATE INDEX idx_fitness_calculations_user_date
ON fitness_calculations(user_id, calculated_at);


-- ============================================
-- 10. EXERCISES
-- Shared master exercise catalog
-- ============================================

CREATE TABLE exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(150) NOT NULL,

    category VARCHAR(50) NOT NULL,
    primary_muscle VARCHAR(100) NOT NULL,
    secondary_muscles TEXT NULL,

    equipment_required BOOLEAN NOT NULL DEFAULT FALSE,

    instructions TEXT NULL,
    safety_notes TEXT NULL,

    difficulty_level VARCHAR(30) NOT NULL DEFAULT 'BEGINNER',

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_exercises_name UNIQUE (name),

    CONSTRAINT chk_exercises_category
        CHECK (
            category IN (
                'STRENGTH',
                'CARDIO',
                'FLEXIBILITY',
                'MOBILITY',
                'CORE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_exercises_difficulty
        CHECK (
            difficulty_level IN (
                'BEGINNER',
                'INTERMEDIATE',
                'ADVANCED'
            )
        )
);


-- ============================================
-- 11. WORKOUT PLANS
-- Generated or manually created plans
-- ============================================

CREATE TABLE workout_plans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    name VARCHAR(150) NOT NULL,

    source VARCHAR(30) NOT NULL DEFAULT 'AI',
    version INT NOT NULL DEFAULT 1,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    started_date DATE NULL,
    ended_date DATE NULL,

    generated_by VARCHAR(30) NOT NULL DEFAULT 'AI',

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_workout_plans_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_workout_plan_version
        UNIQUE (user_id, name, version),

    CONSTRAINT chk_workout_plans_source
        CHECK (
            source IN ('AI', 'SYSTEM', 'USER')
        ),

    CONSTRAINT chk_workout_plans_status
        CHECK (
            status IN (
                'DRAFT',
                'ACTIVE',
                'COMPLETED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_workout_plans_version
        CHECK (version > 0)
);

CREATE INDEX idx_workout_plans_user_status
ON workout_plans(user_id, status);


-- ============================================
-- 12. WORKOUT PLAN EXERCISES
-- Exercises assigned inside a workout plan
-- ============================================

CREATE TABLE workout_plan_exercises (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    workout_plan_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,

    day_number INT NOT NULL,
    exercise_order INT NOT NULL,

    target_sets INT NOT NULL,
    target_reps VARCHAR(50) NOT NULL,

    target_weight_kg DECIMAL(7,2) NULL,
    rest_seconds INT NULL,

    notes TEXT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_workout_plan_exercises_plan
        FOREIGN KEY (workout_plan_id)
        REFERENCES workout_plans(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_workout_plan_exercises_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES exercises(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_workout_plan_day_order
        UNIQUE (
            workout_plan_id,
            day_number,
            exercise_order
        ),

    CONSTRAINT chk_workout_plan_day
        CHECK (day_number > 0),

    CONSTRAINT chk_workout_plan_exercise_order
        CHECK (exercise_order > 0),

    CONSTRAINT chk_workout_plan_sets
        CHECK (target_sets > 0),

    CONSTRAINT chk_workout_plan_weight
        CHECK (
            target_weight_kg IS NULL
            OR target_weight_kg >= 0
        ),

    CONSTRAINT chk_workout_plan_rest
        CHECK (
            rest_seconds IS NULL
            OR rest_seconds >= 0
        )
);


-- ============================================
-- 13. WORKOUT SESSIONS
-- Actual workout performed by the user
-- ============================================

CREATE TABLE workout_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    workout_plan_id BIGINT NULL,

    started_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    completed_at DATETIME(6) NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS',

    feedback TEXT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_workout_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_workout_sessions_plan
        FOREIGN KEY (workout_plan_id)
        REFERENCES workout_plans(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_workout_sessions_status
        CHECK (
            status IN (
                'IN_PROGRESS',
                'COMPLETED',
                'ABANDONED'
            )
        ),

    CONSTRAINT chk_workout_session_dates
        CHECK (
            completed_at IS NULL
            OR completed_at >= started_at
        )
);

CREATE INDEX idx_workout_sessions_user_date
ON workout_sessions(user_id, started_at);


-- ============================================
-- 14. EXERCISE PERFORMANCES
-- What the user actually performed
-- ============================================

CREATE TABLE exercise_performances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    workout_session_id BIGINT NOT NULL,
    exercise_id BIGINT NOT NULL,

    exercise_order INT NOT NULL,

    planned_sets INT NULL,
    completed_sets INT NOT NULL DEFAULT 0,

    actual_reps VARCHAR(100) NULL,
    actual_weight_kg DECIMAL(7,2) NULL,

    perceived_difficulty INT NULL,

    pain_reported BOOLEAN NOT NULL DEFAULT FALSE,

    notes TEXT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_exercise_performances_session
        FOREIGN KEY (workout_session_id)
        REFERENCES workout_sessions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_exercise_performances_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES exercises(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_exercise_performance_order
        UNIQUE (workout_session_id, exercise_order),

    CONSTRAINT chk_exercise_performance_order
        CHECK (exercise_order > 0),

    CONSTRAINT chk_exercise_performance_planned_sets
        CHECK (
            planned_sets IS NULL
            OR planned_sets >= 0
        ),

    CONSTRAINT chk_exercise_performance_completed_sets
        CHECK (completed_sets >= 0),

    CONSTRAINT chk_exercise_performance_weight
        CHECK (
            actual_weight_kg IS NULL
            OR actual_weight_kg >= 0
        ),

    CONSTRAINT chk_exercise_performance_difficulty
        CHECK (
            perceived_difficulty IS NULL
            OR perceived_difficulty BETWEEN 1 AND 10
        )
);
SHOW TABLES;
DESCRIBE fitness_calculations;
DESCRIBE exercises;
DESCRIBE workout_plans;
DESCRIBE workout_plan_exercises;
DESCRIBE workout_sessions;
DESCRIBE exercise_performances;
USE ai_fitness_platform;

-- ============================================
-- 15. NUTRITION PLANS
-- Personalized nutrition plans for users
-- ============================================

CREATE TABLE nutrition_plans (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    name VARCHAR(150) NOT NULL,

    source VARCHAR(30) NOT NULL DEFAULT 'AI',
    version INT NOT NULL DEFAULT 1,

    daily_calorie_target DECIMAL(10,2) NOT NULL,
    protein_target_g DECIMAL(10,2) NOT NULL,
    carbs_target_g DECIMAL(10,2) NOT NULL,
    fat_target_g DECIMAL(10,2) NOT NULL,

    budget_target DECIMAL(12,2) NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_nutrition_plans_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_nutrition_plan_version
        UNIQUE (user_id, name, version),

    CONSTRAINT chk_nutrition_plans_source
        CHECK (
            source IN ('AI', 'SYSTEM', 'USER')
        ),

    CONSTRAINT chk_nutrition_plans_status
        CHECK (
            status IN (
                'DRAFT',
                'ACTIVE',
                'COMPLETED',
                'ARCHIVED'
            )
        ),

    CONSTRAINT chk_nutrition_plan_version
        CHECK (version > 0),

    CONSTRAINT chk_nutrition_calories
        CHECK (daily_calorie_target >= 0),

    CONSTRAINT chk_nutrition_protein
        CHECK (protein_target_g >= 0),

    CONSTRAINT chk_nutrition_carbs
        CHECK (carbs_target_g >= 0),

    CONSTRAINT chk_nutrition_fat
        CHECK (fat_target_g >= 0),

    CONSTRAINT chk_nutrition_budget
        CHECK (budget_target IS NULL OR budget_target >= 0)
);

CREATE INDEX idx_nutrition_plans_user_status
ON nutrition_plans(user_id, status);


-- ============================================
-- 16. MEALS
-- Individual meals inside a nutrition plan
-- ============================================

CREATE TABLE meals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    nutrition_plan_id BIGINT NOT NULL,

    name VARCHAR(100) NOT NULL,

    meal_type VARCHAR(30) NOT NULL,
    meal_order INT NOT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_meals_nutrition_plan
        FOREIGN KEY (nutrition_plan_id)
        REFERENCES nutrition_plans(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_meals_plan_order
        UNIQUE (nutrition_plan_id, meal_order),

    CONSTRAINT chk_meals_type
        CHECK (
            meal_type IN (
                'BREAKFAST',
                'LUNCH',
                'DINNER',
                'SNACK',
                'PRE_WORKOUT',
                'POST_WORKOUT'
            )
        ),

    CONSTRAINT chk_meals_order
        CHECK (meal_order > 0)
);


-- ============================================
-- 17. MEAL ITEMS
-- Foods inside each meal
-- ============================================

CREATE TABLE meal_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    meal_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,

    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(30) NOT NULL,

    notes TEXT NULL,

    item_order INT NOT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_meal_items_meal
        FOREIGN KEY (meal_id)
        REFERENCES meals(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_meal_items_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_meal_items_order
        UNIQUE (meal_id, item_order),

    CONSTRAINT chk_meal_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_meal_items_order
        CHECK (item_order > 0)
);


-- ============================================
-- 18. FOOD LOGS
-- Actual food consumed by a user
-- Historical user data
-- ============================================

CREATE TABLE food_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,

    consumed_quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(30) NOT NULL,

    meal_type VARCHAR(30) NOT NULL,

    logged_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_food_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_food_logs_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_food_logs_quantity
        CHECK (consumed_quantity > 0),

    CONSTRAINT chk_food_logs_meal_type
        CHECK (
            meal_type IN (
                'BREAKFAST',
                'LUNCH',
                'DINNER',
                'SNACK',
                'PRE_WORKOUT',
                'POST_WORKOUT'
            )
        )
);

CREATE INDEX idx_food_logs_user_date
ON food_logs(user_id, logged_at);
SHOW TABLES;
DESCRIBE nutrition_plans;
DESCRIBE meals;
DESCRIBE meal_items;
DESCRIBE food_logs;
USE ai_fitness_platform;

-- ============================================
-- 19. AI CONVERSATIONS
-- Each conversation belongs to one user
-- ============================================

CREATE TABLE ai_conversations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    title VARCHAR(255) NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_ai_conversations_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_ai_conversations_status
        CHECK (
            status IN ('ACTIVE', 'ARCHIVED')
        )
);

CREATE INDEX idx_ai_conversations_user_status
ON ai_conversations(user_id, status);


-- ============================================
-- 20. AI MESSAGES
-- Individual messages inside a conversation
-- ============================================

CREATE TABLE ai_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    conversation_id BIGINT NOT NULL,

    role VARCHAR(20) NOT NULL,

    content LONGTEXT NOT NULL,

    model_name VARCHAR(100) NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_ai_messages_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES ai_conversations(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_ai_messages_role
        CHECK (
            role IN (
                'USER',
                'ASSISTANT',
                'SYSTEM'
            )
        )
);

CREATE INDEX idx_ai_messages_conversation_date
ON ai_messages(conversation_id, created_at);
SHOW TABLES;
DESCRIBE ai_conversations;
DESCRIBE ai_messages;
USE ai_fitness_platform;

-- ============================================
-- 21. PROGRESS RECORDS
-- Historical body measurements and progress
-- ============================================

CREATE TABLE progress_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    weight_kg DECIMAL(5,2) NULL,
    body_fat_percentage DECIMAL(5,2) NULL,

    chest_cm DECIMAL(5,2) NULL,
    waist_cm DECIMAL(5,2) NULL,
    hip_cm DECIMAL(5,2) NULL,
    arm_cm DECIMAL(5,2) NULL,

    notes TEXT NULL,

    recorded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_progress_records_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_progress_weight
        CHECK (weight_kg IS NULL OR weight_kg > 0),

    CONSTRAINT chk_progress_body_fat
        CHECK (
            body_fat_percentage IS NULL
            OR body_fat_percentage BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_progress_chest
        CHECK (chest_cm IS NULL OR chest_cm > 0),

    CONSTRAINT chk_progress_waist
        CHECK (waist_cm IS NULL OR waist_cm > 0),

    CONSTRAINT chk_progress_hip
        CHECK (hip_cm IS NULL OR hip_cm > 0),

    CONSTRAINT chk_progress_arm
        CHECK (arm_cm IS NULL OR arm_cm > 0)
);

CREATE INDEX idx_progress_records_user_date
ON progress_records(user_id, recorded_at);


-- ============================================
-- 22. MEDIA
-- Metadata only.
-- Actual files are stored externally.
-- ============================================

CREATE TABLE media (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    progress_record_id BIGINT NULL,

    storage_provider VARCHAR(50) NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    file_url VARCHAR(1000) NOT NULL,

    media_type VARCHAR(30) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,

    file_size_bytes BIGINT NOT NULL,

    purpose VARCHAR(50) NOT NULL,

    uploaded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_media_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_media_progress_record
        FOREIGN KEY (progress_record_id)
        REFERENCES progress_records(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_media_storage_key
        UNIQUE (storage_provider, storage_key),

    CONSTRAINT chk_media_type
        CHECK (
            media_type IN ('IMAGE', 'VIDEO')
        ),

    CONSTRAINT chk_media_purpose
        CHECK (
            purpose IN (
                'FORM_ANALYSIS',
                'PROGRESS_PHOTO',
                'PROFILE_IMAGE',
                'OTHER'
            )
        ),

    CONSTRAINT chk_media_file_size
        CHECK (file_size_bytes > 0)
);

CREATE INDEX idx_media_user_purpose
ON media(user_id, purpose);


-- ============================================
-- 23. FORM ANALYSES
-- One analysis request/result for uploaded media
-- ============================================

CREATE TABLE form_analyses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,
    media_id BIGINT NOT NULL,

    exercise_id BIGINT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',

    overall_score DECIMAL(5,2) NULL,

    analyzed_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_form_analyses_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_form_analyses_media
        FOREIGN KEY (media_id)
        REFERENCES media(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_form_analyses_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES exercises(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_form_analyses_status
        CHECK (
            status IN (
                'PENDING',
                'PROCESSING',
                'COMPLETED',
                'FAILED'
            )
        ),

    CONSTRAINT chk_form_analyses_score
        CHECK (
            overall_score IS NULL
            OR overall_score BETWEEN 0 AND 100
        )
);

CREATE INDEX idx_form_analyses_user_date
ON form_analyses(user_id, created_at);

CREATE INDEX idx_form_analyses_status
ON form_analyses(status);


-- ============================================
-- 24. FORM ANALYSIS RESULTS
-- Individual issues detected during analysis
-- ============================================

CREATE TABLE form_analysis_results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    form_analysis_id BIGINT NOT NULL,

    issue_type VARCHAR(100) NOT NULL,
    severity VARCHAR(30) NOT NULL,

    body_part VARCHAR(100) NULL,

    feedback TEXT NOT NULL,

    frame_timestamp_ms BIGINT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_form_analysis_results_analysis
        FOREIGN KEY (form_analysis_id)
        REFERENCES form_analyses(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_form_analysis_results_severity
        CHECK (
            severity IN (
                'LOW',
                'MEDIUM',
                'HIGH'
            )
        ),

    CONSTRAINT chk_form_analysis_results_timestamp
        CHECK (
            frame_timestamp_ms IS NULL
            OR frame_timestamp_ms >= 0
        )
);

CREATE INDEX idx_form_analysis_results_analysis
ON form_analysis_results(form_analysis_id);
SHOW TABLES;
DESCRIBE progress_records;
DESCRIBE media;
DESCRIBE form_analyses;
DESCRIBE form_analysis_results;
USE ai_fitness_platform;

-- ============================================
-- 25. SAFETY RECORDS
-- User-reported injuries, restrictions,
-- discomfort, or other safety-related records
-- ============================================

CREATE TABLE safety_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    record_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    reported_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    resolved_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT fk_safety_records_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_safety_records_type
        CHECK (
            record_type IN (
                'INJURY',
                'RESTRICTION',
                'DISCOMFORT',
                'OTHER'
            )
        ),

    CONSTRAINT chk_safety_records_status
        CHECK (
            status IN (
                'ACTIVE',
                'RESOLVED',
                'INACTIVE'
            )
        ),

    CONSTRAINT chk_safety_records_dates
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= reported_at
        )
);

CREATE INDEX idx_safety_records_user_status
ON safety_records(user_id, status);


-- ============================================
-- 26. SAFETY EVENTS
-- Warnings generated by the system, AI,
-- workout engine, or form analysis
-- ============================================

CREATE TABLE safety_events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT NOT NULL,

    safety_record_id BIGINT NULL,

    event_type VARCHAR(100) NOT NULL,
    severity VARCHAR(30) NOT NULL,

    message TEXT NOT NULL,

    source VARCHAR(50) NOT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    acknowledged_at DATETIME(6) NULL,

    CONSTRAINT fk_safety_events_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_safety_events_record
        FOREIGN KEY (safety_record_id)
        REFERENCES safety_records(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_safety_events_severity
        CHECK (
            severity IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    CONSTRAINT chk_safety_events_source
        CHECK (
            source IN (
                'WORKOUT',
                'AI',
                'FORM_ANALYSIS',
                'SYSTEM'
            )
        )
);

CREATE INDEX idx_safety_events_user_date
ON safety_events(user_id, created_at);


-- ============================================
-- 27. ACHIEVEMENTS
-- Shared master/reference achievement data
-- ============================================

CREATE TABLE achievements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,

    code VARCHAR(100) NOT NULL,

    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,

    criteria_description TEXT NULL,

    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT uq_achievements_code
        UNIQUE (code)
);


-- ============================================
-- 28. USER ACHIEVEMENTS
-- Achievements earned by users
-- ============================================

CREATE TABLE user_achievements (
    user_id BIGINT NOT NULL,
    achievement_id BIGINT NOT NULL,

    earned_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    PRIMARY KEY (user_id, achievement_id),

    CONSTRAINT fk_user_achievements_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_achievements_achievement
        FOREIGN KEY (achievement_id)
        REFERENCES achievements(id)
        ON DELETE RESTRICT
);
SHOW TABLES;
DESCRIBE safety_records;
DESCRIBE safety_events;
DESCRIBE achievements;
DESCRIBE user_achievements;
USE ai_fitness_platform;

INSERT INTO equipment (name, category, description) VALUES

-- Free weights
('Dumbbell', 'FREE_WEIGHT', 'Handheld free weight used for strength training'),
('Barbell', 'FREE_WEIGHT', 'Long bar used for compound strength exercises'),
('Weight Plates', 'FREE_WEIGHT', 'Plates used to add resistance to barbells and machines'),
('Kettlebell', 'FREE_WEIGHT', 'Cast iron or steel weight with a handle'),

-- Benches
('Flat Bench', 'BENCH', 'Flat bench for pressing and other exercises'),
('Adjustable Bench', 'BENCH', 'Bench adjustable for flat, incline and seated exercises'),

-- Bodyweight / bars
('Pull-up Bar', 'BODYWEIGHT', 'Bar used for pull-ups, chin-ups and hanging exercises'),
('Dip Bars', 'BODYWEIGHT', 'Parallel bars used for dips and bodyweight exercises'),

-- Machines
('Cable Machine', 'MACHINE', 'Cable-based resistance training machine'),
('Leg Press Machine', 'MACHINE', 'Machine for lower body pressing exercises'),
('Lat Pulldown Machine', 'MACHINE', 'Machine for vertical pulling exercises'),
('Chest Press Machine', 'MACHINE', 'Machine for chest pressing exercises'),
('Seated Row Machine', 'MACHINE', 'Machine for horizontal rowing exercises'),
('Leg Extension Machine', 'MACHINE', 'Machine for quadriceps isolation'),
('Leg Curl Machine', 'MACHINE', 'Machine for hamstring isolation'),

-- Portable / simple
('Resistance Band', 'ACCESSORY', 'Elastic resistance band for training'),
('Exercise Mat', 'ACCESSORY', 'Mat for floor exercises and mobility work'),
('Jump Rope', 'CARDIO', 'Rope used for skipping and cardio training'),

-- Minimal equipment
('Bodyweight Only', 'BODYWEIGHT', 'Exercises requiring no external equipment');
USE ai_fitness_platform;
SELECT * 
FROM equipment;
DESCRIBE equipment;
SELECT DATABASE();
SELECT id, name, category
FROM ai_fitness_platform.equipment
ORDER BY id;
USE ai_fitness_platform;

INSERT INTO exercises (
    name,
    category,
    primary_muscle,
    secondary_muscles,
    equipment_required,
    instructions,
    safety_notes,
    difficulty_level
) VALUES

-- ============================================
-- CHEST
-- ============================================
(
    'Push Up',
    'STRENGTH',
    'CHEST',
    'TRICEPS, SHOULDERS',
    FALSE,
    'Keep your body straight, lower your chest toward the floor, then push back up.',
    'Avoid sagging your lower back.',
    'BEGINNER'
),
(
    'Bench Press',
    'STRENGTH',
    'CHEST',
    'TRICEPS, SHOULDERS',
    TRUE,
    'Lower the bar with control to your chest and press upward.',
    'Keep your feet stable and avoid excessive arching.',
    'INTERMEDIATE'
),
(
    'Incline Dumbbell Press',
    'STRENGTH',
    'CHEST',
    'TRICEPS, SHOULDERS',
    TRUE,
    'Press dumbbells upward from an inclined bench.',
    'Use controlled movement and avoid excessive shoulder strain.',
    'INTERMEDIATE'
),
(
    'Dumbbell Fly',
    'STRENGTH',
    'CHEST',
    'SHOULDERS',
    TRUE,
    'Lower dumbbells outward with slightly bent elbows, then bring them together.',
    'Do not lower the weights too far behind the shoulders.',
    'INTERMEDIATE'
),
(
    'Chest Press Machine',
    'STRENGTH',
    'CHEST',
    'TRICEPS, SHOULDERS',
    TRUE,
    'Push the handles forward in a controlled movement.',
    'Keep your back supported against the seat.',
    'BEGINNER'
),

-- ============================================
-- BACK
-- ============================================
(
    'Pull Up',
    'STRENGTH',
    'BACK',
    'BICEPS',
    TRUE,
    'Pull your body upward until your chin passes the bar.',
    'Avoid swinging excessively.',
    'INTERMEDIATE'
),
(
    'Lat Pulldown',
    'STRENGTH',
    'BACK',
    'BICEPS',
    TRUE,
    'Pull the bar toward your upper chest with control.',
    'Do not pull the bar behind your neck.',
    'BEGINNER'
),
(
    'Barbell Row',
    'STRENGTH',
    'BACK',
    'BICEPS, REAR DELTS',
    TRUE,
    'Hinge at the hips and pull the bar toward your torso.',
    'Keep your spine neutral.',
    'INTERMEDIATE'
),
(
    'Seated Cable Row',
    'STRENGTH',
    'BACK',
    'BICEPS',
    TRUE,
    'Pull the handle toward your torso while squeezing your shoulder blades.',
    'Avoid excessive rounding of the lower back.',
    'BEGINNER'
),
(
    'One Arm Dumbbell Row',
    'STRENGTH',
    'BACK',
    'BICEPS',
    TRUE,
    'Support your body and pull the dumbbell toward your hip.',
    'Keep your torso stable.',
    'BEGINNER'
),

-- ============================================
-- SHOULDERS
-- ============================================
(
    'Dumbbell Shoulder Press',
    'STRENGTH',
    'SHOULDERS',
    'TRICEPS',
    TRUE,
    'Press dumbbells upward from shoulder level.',
    'Avoid excessive lower-back arching.',
    'BEGINNER'
),
(
    'Lateral Raise',
    'STRENGTH',
    'SHOULDERS',
    'TRAPEZIUS',
    TRUE,
    'Raise dumbbells outward until approximately shoulder height.',
    'Use light weight and avoid swinging.',
    'BEGINNER'
),
(
    'Front Raise',
    'STRENGTH',
    'SHOULDERS',
    'UPPER CHEST',
    TRUE,
    'Raise the weight forward to shoulder height.',
    'Do not use momentum.',
    'BEGINNER'
),
(
    'Face Pull',
    'STRENGTH',
    'REAR DELTS',
    'UPPER BACK, BICEPS',
    TRUE,
    'Pull the rope toward your face while externally rotating your shoulders.',
    'Use controlled movement.',
    'BEGINNER'
),
(
    'Dumbbell Shrug',
    'STRENGTH',
    'TRAPEZIUS',
    'UPPER BACK',
    TRUE,
    'Lift your shoulders upward and lower them slowly.',
    'Do not roll your shoulders.',
    'BEGINNER'
),

-- ============================================
-- BICEPS
-- ============================================
(
    'Dumbbell Bicep Curl',
    'STRENGTH',
    'BICEPS',
    'FOREARMS',
    TRUE,
    'Curl the dumbbell upward while keeping your elbows relatively stable.',
    'Avoid swinging your body.',
    'BEGINNER'
),
(
    'Hammer Curl',
    'STRENGTH',
    'BICEPS',
    'FOREARMS',
    TRUE,
    'Curl dumbbells using a neutral grip.',
    'Keep your elbows close to your body.',
    'BEGINNER'
),
(
    'Barbell Curl',
    'STRENGTH',
    'BICEPS',
    'FOREARMS',
    TRUE,
    'Curl the bar upward using controlled movement.',
    'Avoid excessive swinging.',
    'INTERMEDIATE'
),

-- ============================================
-- TRICEPS
-- ============================================
(
    'Tricep Pushdown',
    'STRENGTH',
    'TRICEPS',
    'FOREARMS',
    TRUE,
    'Push the cable attachment downward until your elbows are extended.',
    'Keep your elbows close to your body.',
    'BEGINNER'
),
(
    'Dumbbell Tricep Extension',
    'STRENGTH',
    'TRICEPS',
    'SHOULDERS',
    TRUE,
    'Extend the dumbbell by straightening your elbows.',
    'Avoid excessive elbow stress.',
    'BEGINNER'
),
(
    'Bench Dip',
    'STRENGTH',
    'TRICEPS',
    'CHEST, SHOULDERS',
    TRUE,
    'Lower your body by bending your elbows and press back upward.',
    'Avoid going too deep if it causes shoulder discomfort.',
    'BEGINNER'
),

-- ============================================
-- LEGS - QUADRICEPS / GLUTES
-- ============================================
(
    'Bodyweight Squat',
    'STRENGTH',
    'QUADRICEPS',
    'GLUTES, HAMSTRINGS',
    FALSE,
    'Lower your hips by bending your knees and hips, then stand back up.',
    'Keep your knees tracking in line with your feet.',
    'BEGINNER'
),
(
    'Barbell Squat',
    'STRENGTH',
    'QUADRICEPS',
    'GLUTES, HAMSTRINGS, CORE',
    TRUE,
    'Place the bar securely on your upper back, squat with control, and stand up.',
    'Keep your spine neutral and knees controlled.',
    'INTERMEDIATE'
),
(
    'Leg Press',
    'STRENGTH',
    'QUADRICEPS',
    'GLUTES, HAMSTRINGS',
    TRUE,
    'Press the platform away by extending your knees and hips.',
    'Do not lock your knees forcefully.',
    'BEGINNER'
),
(
    'Leg Extension',
    'STRENGTH',
    'QUADRICEPS',
    NULL,
    TRUE,
    'Extend your knees against resistance.',
    'Use controlled movement.',
    'BEGINNER'
),
(
    'Walking Lunge',
    'STRENGTH',
    'QUADRICEPS',
    'GLUTES, HAMSTRINGS',
    FALSE,
    'Step forward and lower your back knee toward the floor.',
    'Keep your front knee controlled.',
    'BEGINNER'
),
(
    'Bulgarian Split Squat',
    'STRENGTH',
    'QUADRICEPS',
    'GLUTES, HAMSTRINGS',
    TRUE,
    'Place one foot behind you on a bench and perform a controlled split squat.',
    'Maintain balance and knee control.',
    'INTERMEDIATE'
),

-- ============================================
-- HAMSTRINGS / POSTERIOR CHAIN
-- ============================================
(
    'Deadlift',
    'STRENGTH',
    'HAMSTRINGS',
    'GLUTES, BACK, CORE',
    TRUE,
    'Lift the weight by extending your hips and knees while maintaining a neutral spine.',
    'Keep the load close and avoid rounding your back.',
    'ADVANCED'
),
(
    'Romanian Deadlift',
    'STRENGTH',
    'HAMSTRINGS',
    'GLUTES, BACK',
    TRUE,
    'Hinge at the hips and lower the weight while keeping your knees slightly bent.',
    'Maintain a neutral spine.',
    'INTERMEDIATE'
),
(
    'Leg Curl',
    'STRENGTH',
    'HAMSTRINGS',
    NULL,
    TRUE,
    'Curl your heels toward your body against resistance.',
    'Use controlled movement.',
    'BEGINNER'
),
(
    'Hip Thrust',
    'STRENGTH',
    'GLUTES',
    'HAMSTRINGS, QUADRICEPS',
    TRUE,
    'Drive your hips upward while keeping your upper back supported.',
    'Avoid excessive lower-back extension.',
    'INTERMEDIATE'
),

-- ============================================
-- CALVES
-- ============================================
(
    'Standing Calf Raise',
    'STRENGTH',
    'CALVES',
    NULL,
    FALSE,
    'Raise your heels upward and lower them with control.',
    'Use a full comfortable range of motion.',
    'BEGINNER'
),
(
    'Seated Calf Raise',
    'STRENGTH',
    'CALVES',
    NULL,
    TRUE,
    'Raise your heels against resistance while seated.',
    'Avoid bouncing.',
    'BEGINNER'
),

-- ============================================
-- CORE
-- ============================================
(
    'Plank',
    'CORE',
    'CORE',
    'SHOULDERS, GLUTES',
    FALSE,
    'Hold a straight body position supported on your forearms or hands.',
    'Avoid allowing your hips to sag.',
    'BEGINNER'
),
(
    'Crunch',
    'CORE',
    'ABDOMINALS',
    NULL,
    FALSE,
    'Lift your upper back slightly from the floor using your abdominal muscles.',
    'Avoid pulling on your neck.',
    'BEGINNER'
),
(
    'Leg Raise',
    'CORE',
    'ABDOMINALS',
    'HIP FLEXORS',
    FALSE,
    'Raise your legs with control and lower them slowly.',
    'Avoid excessive lower-back arching.',
    'BEGINNER'
),
(
    'Ab Wheel Rollout',
    'CORE',
    'CORE',
    'SHOULDERS, BACK',
    TRUE,
    'Roll the wheel forward while keeping your core braced, then return.',
    'Do not allow your lower back to collapse.',
    'ADVANCED'
),

-- ============================================
-- CARDIO
-- ============================================
(
    'Jumping Jacks',
    'CARDIO',
    'FULL BODY',
    'CALVES, SHOULDERS',
    FALSE,
    'Jump while moving your legs apart and raising your arms overhead.',
    'Land softly and maintain control.',
    'BEGINNER'
),
(
    'Jump Rope',
    'CARDIO',
    'CALVES',
    'SHOULDERS, CORE',
    TRUE,
    'Jump lightly while rotating the rope using your wrists.',
    'Land softly.',
    'BEGINNER'
),
(
    'High Knees',
    'CARDIO',
    'HIP FLEXORS',
    'QUADRICEPS, CORE',
    FALSE,
    'Run in place while lifting your knees upward.',
    'Maintain controlled posture.',
    'BEGINNER'
),
(
    'Burpee',
    'CARDIO',
    'FULL BODY',
    'CHEST, QUADRICEPS, CORE',
    FALSE,
    'Move from standing to a plank or push-up position and return to standing.',
    'Modify the movement if impact causes discomfort.',
    'INTERMEDIATE'
),

-- ============================================
-- MOBILITY / FLEXIBILITY
-- ============================================
(
    'Cat Cow Stretch',
    'MOBILITY',
    'SPINE',
    'CORE',
    FALSE,
    'Move slowly between spinal flexion and extension on hands and knees.',
    'Stay within a comfortable range of motion.',
    'BEGINNER'
),
(
    'Child Pose',
    'FLEXIBILITY',
    'BACK',
    'HIPS, SHOULDERS',
    FALSE,
    'Sit your hips toward your heels and extend your arms forward.',
    'Do not force the stretch.',
    'BEGINNER'
),
(
    'Hip Flexor Stretch',
    'FLEXIBILITY',
    'HIP FLEXORS',
    'QUADRICEPS',
    FALSE,
    'Use a controlled lunge position to stretch the front of the hip.',
    'Avoid forcing the stretch.',
    'BEGINNER'
),
(
    'Hamstring Stretch',
    'FLEXIBILITY',
    'HAMSTRINGS',
    NULL,
    FALSE,
    'Stretch the back of your thigh with a controlled movement.',
    'Avoid bouncing.',
    'BEGINNER'
);
SELECT COUNT(*) AS total_exercises
FROM exercises;
SELECT id, name, category, primary_muscle, difficulty_level
FROM exercises
ORDER BY category, primary_muscle, name;
USE ai_fitness_platform;

INSERT INTO foods (
    name,
    serving_size,
    serving_unit,
    calories,
    protein_g,
    carbs_g,
    fat_g
) VALUES

-- ============================================
-- EGGS & DAIRY
-- ============================================
('Whole Egg', 1, 'piece', 72, 6.3, 0.4, 4.8),
('Egg White', 1, 'piece', 17, 3.6, 0.2, 0.1),
('Milk', 250, 'ml', 150, 8.0, 12.0, 8.0),
('Curd', 100, 'g', 98, 11.0, 3.4, 4.3),
('Paneer', 100, 'g', 265, 18.3, 1.2, 20.8),

-- ============================================
-- RICE & GRAINS
-- ============================================
('Cooked White Rice', 100, 'g', 130, 2.7, 28.0, 0.3),
('Chapati', 1, 'piece', 104, 3.1, 18.0, 3.0),
('Oats', 50, 'g', 195, 8.5, 33.0, 3.5),
('Bread', 2, 'slices', 160, 6.0, 30.0, 2.0),
('Idli', 1, 'piece', 58, 2.0, 12.0, 0.4),

-- ============================================
-- DAL & LEGUMES
-- ============================================
('Cooked Dal', 100, 'g', 116, 9.0, 20.0, 0.4),
('Chickpeas', 100, 'g', 164, 8.9, 27.4, 2.6),
('Moong Sprouts', 100, 'g', 30, 3.0, 6.0, 0.2),
('Peanuts', 30, 'g', 170, 7.7, 4.8, 14.5),

-- ============================================
-- FRUITS
-- ============================================
('Banana', 1, 'piece', 105, 1.3, 27.0, 0.4),
('Apple', 1, 'piece', 95, 0.5, 25.0, 0.3),
('Orange', 1, 'piece', 62, 1.2, 15.4, 0.2),

-- ============================================
-- NUTS
-- ============================================
('Almonds', 30, 'g', 174, 6.4, 6.1, 15.0),
('Cashews', 30, 'g', 166, 5.5, 9.1, 13.1),
('Walnuts', 30, 'g', 196, 4.6, 4.1, 19.6),

-- ============================================
-- FITNESS FOODS
-- ============================================
('Peanut Butter', 32, 'g', 188, 8.0, 6.0, 16.0),
('Whey Protein', 30, 'g', 120, 24.0, 3.0, 2.0),
('Mass Gainer', 50, 'g', 200, 13.0, 32.0, 3.0),

-- ============================================
-- COMMON HOSTEL / INDIAN FOODS
-- ============================================
('Sambar', 150, 'ml', 90, 4.0, 15.0, 2.0),
('Vegetable Curry', 150, 'g', 150, 4.0, 18.0, 7.0),
('Chicken Curry', 150, 'g', 250, 25.0, 8.0, 12.0),
('Grilled Chicken', 100, 'g', 165, 31.0, 0.0, 3.6),
('Fish Curry', 150, 'g', 220, 22.0, 7.0, 11.0);
SELECT COUNT(*) AS total_foods
FROM foods;
SELECT id, name, serving_size, serving_unit, calories, protein_g
FROM foods
ORDER BY name;
USE ai_fitness_platform;

INSERT INTO achievements (
    code,
    name,
    description,
    criteria_description
) VALUES

(
    'FIRST_WORKOUT',
    'First Workout',
    'Completed your first workout session.',
    'Complete 1 workout session'
),
(
    'WORKOUT_STREAK_3',
    '3 Day Streak',
    'Completed workouts for 3 consecutive days.',
    'Maintain a 3-day workout streak'
),
(
    'WORKOUT_STREAK_7',
    '7 Day Streak',
    'Completed workouts for 7 consecutive days.',
    'Maintain a 7-day workout streak'
),
(
    'WORKOUT_10',
    'Getting Started',
    'Completed 10 workout sessions.',
    'Complete 10 workout sessions'
),
(
    'WORKOUT_50',
    'Dedicated Athlete',
    'Completed 50 workout sessions.',
    'Complete 50 workout sessions'
),
(
    'FIRST_PROGRESS_LOG',
    'Progress Tracker',
    'Recorded your first progress entry.',
    'Create 1 progress record'
),
(
    'WEIGHT_GOAL_REACHED',
    'Goal Achieved',
    'Reached your active target weight goal.',
    'Reach the target weight of an active goal'
),
(
    'FIRST_FOOD_LOG',
    'Food Logger',
    'Logged your first food entry.',
    'Create 1 food log'
),
(
    'NUTRITION_STREAK_7',
    'Nutrition Consistency',
    'Logged food for 7 consecutive days.',
    'Maintain a 7-day food logging streak'
),
(
    'FORM_ANALYSIS_FIRST',
    'Form Check',
    'Completed your first exercise form analysis.',
    'Complete 1 form analysis'
);
SELECT COUNT(*) AS total_achievements
FROM achievements;
SELECT id, code, name, description
FROM achievements
ORDER BY id;
USE ai_fitness_platform;

SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'ai_fitness_platform';
SELECT 'equipment' AS table_name, COUNT(*) AS total FROM equipment
UNION ALL
SELECT 'exercises', COUNT(*) FROM exercises
UNION ALL
SELECT 'foods', COUNT(*) FROM foods
UNION ALL
SELECT 'achievements', COUNT(*) FROM achievements;
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ai_fitness_platform'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;
START TRANSACTION;

-- Create temporary test user
INSERT INTO users (
    email,
    password_hash,
    auth_provider,
    account_status
)
VALUES (
    'test_user@example.com',
    'TEST_HASH_NOT_A_REAL_PASSWORD',
    'LOCAL',
    'ACTIVE'
);

SET @test_user_id = LAST_INSERT_ID();


-- Create profile
INSERT INTO user_profiles (
    user_id,
    full_name,
    gender,
    date_of_birth,
    height_cm,
    current_weight_kg,
    fitness_experience
)
VALUES (
    @test_user_id,
    'Test User',
    'MALE',
    '2000-01-01',
    175.00,
    70.00,
    'BEGINNER'
);


-- Create goal
INSERT INTO user_goals (
    user_id,
    goal_type,
    target_weight_kg,
    target_date,
    status
)
VALUES (
    @test_user_id,
    'MUSCLE_GAIN',
    75.00,
    '2027-01-01',
    'ACTIVE'
);


-- Create fitness calculation
INSERT INTO fitness_calculations (
    user_id,
    bmi,
    bmr,
    tdee,
    calorie_target,
    protein_target_g,
    carbs_target_g,
    fat_target_g
)
VALUES (
    @test_user_id,
    22.86,
    1700.00,
    2500.00,
    2800.00,
    150.00,
    380.00,
    80.00
);


-- Create workout plan
INSERT INTO workout_plans (
    user_id,
    name,
    source,
    version,
    status
)
VALUES (
    @test_user_id,
    'Test Muscle Gain Plan',
    'SYSTEM',
    1,
    'ACTIVE'
);

SET @test_workout_plan_id = LAST_INSERT_ID();


-- Add an exercise to plan
INSERT INTO workout_plan_exercises (
    workout_plan_id,
    exercise_id,
    day_number,
    exercise_order,
    target_sets,
    target_reps,
    target_weight_kg,
    rest_seconds
)
SELECT
    @test_workout_plan_id,
    id,
    1,
    1,
    3,
    '8-12',
    20.00,
    90
FROM exercises
WHERE name = 'Push Up'
LIMIT 1;


-- Create nutrition plan
INSERT INTO nutrition_plans (
    user_id,
    name,
    source,
    version,
    daily_calorie_target,
    protein_target_g,
    carbs_target_g,
    fat_target_g,
    status
)
VALUES (
    @test_user_id,
    'Test Nutrition Plan',
    'SYSTEM',
    1,
    2800.00,
    150.00,
    380.00,
    80.00,
    'ACTIVE'
);

SET @test_nutrition_plan_id = LAST_INSERT_ID();


-- Create meal
INSERT INTO meals (
    nutrition_plan_id,
    name,
    meal_type,
    meal_order
)
VALUES (
    @test_nutrition_plan_id,
    'Test Breakfast',
    'BREAKFAST',
    1
);

SET @test_meal_id = LAST_INSERT_ID();


-- Add food to meal
INSERT INTO meal_items (
    meal_id,
    food_id,
    quantity,
    unit,
    item_order
)
SELECT
    @test_meal_id,
    id,
    2,
    'piece',
    1
FROM foods
WHERE name = 'Whole Egg'
LIMIT 1;


-- Test achievement relationship
INSERT INTO user_achievements (
    user_id,
    achievement_id
)
SELECT
    @test_user_id,
    id
FROM achievements
WHERE code = 'FIRST_WORKOUT'
LIMIT 1;


-- View complete test user
SELECT
    u.id,
    u.email,
    p.full_name,
    g.goal_type,
    wp.name AS workout_plan,
    np.name AS nutrition_plan
FROM users u
LEFT JOIN user_profiles p ON p.user_id = u.id
LEFT JOIN user_goals g ON g.user_id = u.id
LEFT JOIN workout_plans wp ON wp.user_id = u.id
LEFT JOIN nutrition_plans np ON np.user_id = u.id
WHERE u.id = @test_user_id;
SELECT * FROM users
WHERE email = 'test_user@example.com';

-- Remove all test data safely
ROLLBACK;
SELECT COUNT(*) AS test_users_remaining
FROM users
WHERE email = 'test_user@example.com';