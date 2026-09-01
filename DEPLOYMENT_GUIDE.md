# AI Fitness Platform - Managed Cloud Deployment Guide

This guide walks you through deploying the complete AI Fitness Platform to **Managed Cloud Platforms** (Render / Railway for the backend stack, and Firebase Hosting / Vercel for the Flutter Frontend).

---

## Architecture Overview in Production

```mermaid
graph TD
    FlutterClient[Flutter Web / Android App]
    
    subgraph Managed Cloud Provider (Render / Railway)
        MySQL[(Managed MySQL Database)]
        Backend[Spring Boot Backend]
        Agent[Python AI Agent Service]
        CV[Python CV Exercise Service]
    end

    Groq[Groq Cloud LLM API]

    FlutterClient -->|HTTPS REST| Backend
    Backend -->|Internal Private URL| CV
    Backend -->|Internal Private URL| Agent
    Backend -->|Private JDBC| MySQL
    Backend -->|Groq API| Groq
    Agent -->|Groq API| Groq
```

---

## Step 1: Deploy Backend Stack to Render (Recommended)

Render allows 1-click infrastructure deployment using the included [`render.yaml`](./render.yaml) blueprint.

### 1. Push Code to GitHub / GitLab
Make sure your repository is pushed to your Git account.

### 2. Connect Repository on Render
1. Go to [dashboard.render.com](https://dashboard.render.com/) and click **New +** $\rightarrow$ **Blueprint**.
2. Select your `AI_Fitness_Platform` repository.
3. Render will automatically detect the [`render.yaml`](./render.yaml) file and provision:
   - **`ai-fitness-mysql`**: Managed MySQL Database instance.
   - **`ai-fitness-backend`**: Dockerized Spring Boot Monolith.
   - **`ai-fitness-agent`**: Dockerized Python AI Agent.
   - **`cv-exercise-analysis`**: Dockerized Python CV Service.

### 3. Set Environment Secrets in Render Dashboard
In the Blueprint configuration prompt, enter your secrets:
- `GROQ_API_KEY`: `your_groq_api_key_here`
- `JWT_SECRET`: *(Auto-generated or custom 256-bit string)*

### 4. Seed the Database
Connect to your Render MySQL database via MySQL Workbench or CLI and run the schema script:
```bash
mysql -h <render-mysql-host> -u <user> -p <database-name> < "SQL file.sql"
```

### 5. Copy Your Live Backend URL
Once deployed, copy your Spring Boot URL (e.g. `https://ai-fitness-backend.onrender.com`).

---

## Step 2: Deploy Frontend (Flutter Web) to Firebase Hosting or Vercel

### Option A: Firebase Hosting (Free & Instant)
1. Install Firebase CLI (if not installed):
   ```bash
   npm install -g firebase-tools
   firebase login
   ```
2. Initialize Firebase in `ai_fitness_app` (select Hosting):
   ```bash
   cd ai_fitness_app
   firebase init hosting
   ```
   *(Set public directory to `build/web` and configure as single-page app: `Yes`)*
3. Build for production with your live Render backend URL:
   ```bash
   flutter build web --release --dart-define=API_BASE_URL=https://ai-fitness-backend.onrender.com
   ```
4. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

### Option B: Vercel (Free & Instant)
1. Build the web app:
   ```bash
   cd ai_fitness_app
   flutter build web --release --dart-define=API_BASE_URL=https://ai-fitness-backend.onrender.com
   ```
2. Deploy with Vercel CLI or connect via GitHub:
   ```bash
   vercel --prod
   ```

---

## Step 3: Build & Distribute Android Release APK

To distribute the mobile app to Android users:

1. Double-click or execute [`scripts/build_android_apk.bat`](./scripts/build_android_apk.bat) (or run in PowerShell):
   ```powershell
   cd d:\Projects\AI_Fitness_Platform\ai_fitness_app
   flutter build apk --release --dart-define=API_BASE_URL=https://ai-fitness-backend.onrender.com
   ```
2. The generated production APK is located at:
   ```
   ai_fitness_app/build/app/outputs/flutter-apk/app-release.apk
   ```
3. Share this `.apk` file for direct installation on any Android phone.

---

## Alternative: Local / Cloud VPS Deployment (Docker Compose)

If you ever want to test the full stack with 1 command locally or on a VPS:
```bash
# 1. Copy environment template
cp .env.example .env

# 2. Fill in GROQ_API_KEY in .env

# 3. Spin up all 4 containers
docker compose up -d --build
```
- Backend will be live at `http://localhost:8080`
- Agent at `http://localhost:8000`
- CV Analysis at `http://localhost:5000`
- MySQL at `localhost:3306`

