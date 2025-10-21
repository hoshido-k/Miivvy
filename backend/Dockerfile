# Use official Python runtime as base image
FROM python:3.12-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml ./

# Install dependencies using uv
RUN uv pip install --system --no-cache -r pyproject.toml

# Copy application code
COPY . .

# Set environment variables
ENV PORT=8080
ENV PYTHONUNBUFFERED=1

# Run the application using gunicorn
CMD exec uv run gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
