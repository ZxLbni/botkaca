FROM alpine:latest as prepare_env
WORKDIR /app

# Install Python and build tools
RUN apk --no-cache -q add \
    python3 python3-dev py3-pip libffi libffi-dev musl-dev gcc

# Create virtual environment
RUN python3 -m venv /app/venv

# Activate venv and install dependencies
ENV PATH="/app/venv/bin:$PATH" \
    VIRTUAL_ENV="/app/venv"

COPY requirements.txt .
RUN /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install -r requirements.txt

# Copy bot source code (optional: if needed in build phase)
COPY bot bot


# ----------- Final Minimal Image ------------
FROM alpine:latest as execute
WORKDIR /app

# Install runtime deps only
RUN apk --no-cache -q add \
    python3 libffi \
    aria2 ffmpeg

# Copy only the venv (includes Python + site-packages)
COPY --from=prepare_env /app/venv /app/venv
COPY --from=prepare_env /app/bot /app/bot

# Activate virtual env in PATH
ENV PATH="/app/venv/bin:$PATH" \
    VIRTUAL_ENV="/app/venv"

CMD ["python3", "-m", "bot"]
