---
title: AI Fitness Backend Monolith
emoji: 🏋️
colorFrom: indigo
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# AI Fitness Platform - Spring Boot Backend

Production Java 21 / Spring Boot 4.1 backend for the AI Fitness Platform.
Manages JWT authentication, onboarding health questionnaires, workout and nutrition tracking, dashboard analytics, and AI Coach orchestration.

### Configuration
Set the following Secrets in your Space settings:
- `DB_URL`: Managed MySQL JDBC URL (with `useSSL=true`)
- `DB_USERNAME`: Database user
- `DB_PASSWORD`: Database password
- `GROQ_API_KEY`: Groq Cloud API Key
- `GROQ_MODEL`: `qwen/qwen3.8-27b`
- `JWT_SECRET`: 256-bit signing key
- `CV_BASE_URL`: URL of the deployed CV service

### Health Check
- `GET /health` or `GET /api/v1/health`

