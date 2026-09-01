# AI Fitness Platform - Backend Walkthrough (V0.3 SIH MVP)

This document outlines the current state of the Spring Boot backend, what has been implemented, and what remains to be connected by the Frontend and CV teams.

## Architecture Overview
The backend is built as a **Modular Monolith** using **Java 21**, **Spring Boot**, and **MySQL**. 
It handles User Authentication, Profile Management, AI Coaching (via Groq), Form Analysis routing, and Gamification.

### Authentication
- **Mechanism**: We are using standard **JWT (JSON Web Tokens)**. **Supabase Auth is NOT used.**
- **Storage**: User credentials (BCrypt hashed) and profiles are stored directly in the MySQL `users` and `user_profiles` tables.
- **Endpoints**:
  - `POST /api/v1/auth/signup` - Expects email and password. Returns JWT.
  - `POST /api/v1/auth/login` - Expects email and password. Returns JWT.
- **Usage**: Frontend must pass the token in the `Authorization: Bearer <token>` header for all protected endpoints.

### Modules Implemented

#### 1. Onboarding & Health Risk Engine
- **Endpoint**: `POST /api/v1/onboarding`
- **Functionality**: Saves the user's profile, equipment, and parses health conditions (e.g., injuries).
- **Risk Engine**: The `RiskEngine` automatically evaluates user conditions and flags safety risks (e.g., if a user has a "SEVERE" condition, it returns `MEDICAL_REVIEW`).

#### 2. AI Coach (Groq Integration)
- **Endpoint**: `POST /api/v1/coach/chat`
- **Functionality**: Integrates with Groq's LLM (`llama3-70b-8192`). It builds context from the user's profile (height, weight, goals) and provides personalized fitness advice.
- **Safety Filter**: If the user's message contains high-risk keywords (e.g., "chest pain", "dizzy"), the `CoachService` intercepts the request and advises consulting a doctor *before* sending it to Groq.

#### 3. Workout & Nutrition Engines
- **Entities Added**: `WorkoutSession`, `WorkoutExerciseLog`, `NutritionTarget`.
- **Functionality**: Controllers are present (`WorkoutController`, `NutritionController`) to fetch plans and log progress. 
- **Next to Done**: The exact generation logic that maps Groq's JSON output to these specific entities needs final tuning based on the UI flow.

#### 4. Form Analysis & CV Integration
- **Endpoint**: `POST /api/v1/form-analysis/analyze`
- **Payload**: Expects `multipart/form-data` with `exerciseCode` (String) and `video` (File).
- **Functionality**: 
  1. Receives the video from Flutter.
  2. Uploads the video to Supabase Storage (currently stubbed in `StorageService.java`).
  3. Prepares a call to the Python CV Service (currently stubbed to `http://localhost:5000/api/analyze`).
- **Next to Done (For CV Lead)**: Replace the stub in `FormAnalysisService.java` with the actual `RestTemplate` call to the Python CV microservice and map the response correctly.

#### 5. Gamification (Dashboard)
- **Endpoint**: `GET /api/v1/dashboard`
- **Functionality**: Aggregates user progress, calculates current workout streaks, and formats the daily dashboard view.

## Setup Instructions for Development
1. Ensure **MySQL** is running locally on port `3306`.
2. Create a database named `ai_fitness_db`.
3. Configure `GROQ_API_KEY` in your environment variables or directly in `application.yml`.
4. Run the application using Maven:
   ```bash
   mvn spring-boot:run
   ```
   *(Note: Flyway/Hibernate will automatically create the tables based on the entities).*

## Outstanding Tasks for Integration
- **CV Team**: Provide the exact payload structure your Python service expects and returns, so we can update the `FormAnalysisService` mapping.
- **Frontend Team**: Connect the UI to the `POST /api/v1/onboarding` and test the JWT Bearer flow.
