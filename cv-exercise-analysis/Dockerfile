# ==========================================
# Dockerfile for CV Exercise Analysis Service
# ==========================================

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for OpenCV and MediaPipe (including audio/video decoders)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    libasound2 \
    libportaudio2 \
    && rm -rf /var/lib/apt/lists/*

# Set up non-root user for security
RUN useradd -m -u 1000 user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=7860

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code and assign ownership
COPY . .
RUN chown -R user:user /app
USER user

# Expose cloud container port
EXPOSE 7860

# Run FastAPI app with dynamic port binding (compatible with Render $PORT and HF Spaces)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-7860} --workers 2"]
