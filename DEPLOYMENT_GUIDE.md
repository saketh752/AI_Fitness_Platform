# AI Fitness Platform - Cloud Deployment Guide

This guide walks you through deploying the complete AI Fitness Platform to **Managed Cloud Platforms** (Railway, Render, Koyeb, or Cloudflare Tunnel) and deploying the Flutter Frontend to **Firebase Hosting / Vercel / Android APK**.

---

## Architecture Overview in Production

```mermaid
graph TD
    FlutterClient[Flutter Web / Android App]
    
    subgraph Managed Cloud Provider (Railway / Render / VPS)
        MySQL[(Managed MySQL Database)]
        Backend[Spring Boot Monolith Backend]
        Agent[Python AI Agent Service]
        CV[Python CV Exercise Service]
    end

    Groq[Groq Cloud LLM API]

    FlutterClient -->|HTTPS REST| Backend
    Backend -->|Internal Networking| CV
    Backend -->|Internal Networking| Agent
    Backend -->|JDBC Connection| MySQL
    Backend -->|Groq API| Groq
    Agent -->|Groq API| Groq
```

---

## 🚀 Option 1: Deploy to Railway (Recommended)

Railway ([railway.com](https://railway.com)) provides an interactive canvas to deploy Docker microservices and native MySQL.

### Step 1: Create a Railway Project & Add MySQL
1. Go to **[railway.com](https://railway.com)** and log in with your GitHub account.
2. Click **New Project** $\rightarrow$ **Provision MySQL**.
3. Railway will spin up a managed MySQL instance. Click on the MySQL card and note its internal connection details (or use Railway's native variable references).

### Step 2: Deploy the 3 Microservices from GitHub
In the same project canvas:

#### A. Add Spring Boot Backend Service:
1. Click **+ Create** / **New** $\rightarrow$ **GitHub Repo** $\rightarrow$ Select `AI_Fitness_Platform`.
2. Go to the new service **Settings**:
   - **Root Directory**: Set to `/ai-fitness-Backend`
   - **Dockerfile Path**: `Dockerfile`
3. Go to the **Variables** tab and add:
   ```properties
   DB_URL=jdbc:mysql://${{MySQL.MYSQLHOST}}:${{MySQL.MYSQLPORT}}/${{MySQL.MYSQLDATABASE}}?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
   DB_USERNAME=${{MySQL.MYSQLUSER}}
   DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
   GROQ_API_KEY=your_groq_api_key_here
   GROQ_MODEL=qwen/qwen3.8-27b
   JWT_SECRET=4b1f63e9f45d8b8a7b9e8b4562c1d4e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3
   CV_BASE_URL=http://${{cv-service.RAILWAY_PRIVATE_DOMAIN}}:5000
   AGENT_BASE_URL=http://${{ai-agent.RAILWAY_PRIVATE_DOMAIN}}:8000
   PORT=8080
   ```
4. Go to **Networking** and click **Generate Domain** (e.g. `https://ai-fitness-backend.up.railway.app`).

#### B. Add Python AI Agent Service:
1. Click **+ Create** $\rightarrow$ **GitHub Repo** $\rightarrow$ Select `AI_Fitness_Platform`.
2. In **Settings**:
   - **Service Name**: `ai-agent`
   - **Root Directory**: Set to `/ai-agent`
   - **Dockerfile Path**: `Dockerfile`
3. In **Variables**:
   ```properties
   ENVIRONMENT=production
   GROQ_API_KEY=your_groq_api_key_here
   GROQ_MODEL=qwen/qwen3.8-27b
   PORT=8000
   ```
4. In **Settings** $\rightarrow$ **Networking**, enable **Private Networking**.

#### C. Add Python CV Exercise Analysis Service:
1. Click **+ Create** $\rightarrow$ **GitHub Repo** $\rightarrow$ Select `AI_Fitness_Platform`.
2. In **Settings**:
   - **Service Name**: `cv-service`
   - **Root Directory**: Set to `/cv-exercise-analysis`
   - **Dockerfile Path**: `Dockerfile`
3. In **Settings** $\rightarrow$ **Networking**, enable **Private Networking**.

### Step 3: Seed the Database
In Railway, click on the **MySQL** card $\rightarrow$ **Data** tab $\rightarrow$ or connect via your local MySQL Workbench / CLI using the **Connect** tab credentials and execute the contents of [`SQL file.sql`](./SQL%20file.sql).

---

## 🆓 Option 2: 100% Free Without Credit Card (Koyeb + Aiven)

If you do not want to provide a credit card:

1. **Free MySQL Database**:
   - Create a free MySQL database on **[Aiven.io](https://aiven.io)** (No credit card required).
   - Run [`SQL file.sql`](./SQL%20file.sql) to create the schema.
2. **Free Web Microservices**:
   - Connect your GitHub repo on **[Koyeb.com](https://koyeb.com)** (Free hobby tier, no credit card required).
   - Deploy `ai-fitness-Backend`, `ai-agent`, and `cv-exercise-analysis` using their respective Dockerfiles.
   - Point the `DB_URL` in backend variables to your Aiven MySQL database URI.

---

## ⚡ Option 3: Free Cloudflare Tunnel (Live Public HTTPS from Your PC)

If you want to run the full Docker stack locally and instantly expose it to the internet on a secure HTTPS domain for your mobile app:

1. Start your local stack:
   ```bash
   cp .env.example .env
   # Add your GROQ_API_KEY to .env
   docker compose up -d --build
   ```
2. Run Cloudflare Tunnel (zero installation, zero credit card, 1 command):
   ```cmd
   npx -y cloudflared tunnel --url http://localhost:8080
   ```
3. Cloudflare will output a live HTTPS URL:
   ```
   https://random-subdomain.trycloudflare.com -> http://localhost:8080
   ```
4. Use this URL as your `API_BASE_URL` in Flutter!

---

## 📱 Frontend Deployment (Flutter Web & Mobile)

### 1. Deploy Flutter Web to Firebase Hosting (Free)
```bash
# 1. Build Web bundle with your live backend URL
cd ai_fitness_app
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.up.railway.app

# 2. Deploy to Firebase
firebase deploy --only hosting
```

### 2. Deploy Flutter Web to Vercel (Free)
```bash
cd ai_fitness_app
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.up.railway.app
vercel --prod
```

### 3. Build Release Android APK (.apk)
To test and install the production app on your Android phone:
1. Run the build script:
   ```cmd
   cd d:\Projects\AI_Fitness_Platform\scripts
   build_android_apk.bat
   ```
2. Enter your live backend URL (e.g. `https://your-backend.up.railway.app`).
3. The generated release APK will be saved at:
   ```
   ai_fitness_app\build\app\outputs\flutter-apk\app-release.apk
   ```
4. Transfer and install this APK on any Android phone.

---

## 📄 Alternative: Render Blueprint (If Card Added)
If you use Render, simply connect your repo at [dashboard.render.com](https://dashboard.render.com/) $\rightarrow$ **New +** $\rightarrow$ **Blueprint**, select this repository, and Render will automatically read [`render.yaml`](./render.yaml).
