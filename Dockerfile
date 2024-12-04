FROM python:3.12-slim-bookworm AS base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

FROM base AS build
WORKDIR /app

# Install dependencies
COPY pyproject.toml uv.lock /app/
RUN uv sync --frozen

# Load model
RUN uv run python -c 'from transformers import BlipForConditionalGeneration, BlipProcessor;BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base");model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-base")'

# Copy source code
COPY main.py .

FROM build AS deploy
# Run the server
EXPOSE 8080
CMD ["uv", "run", "gunicorn main:app -k gevent --bind 0.0.0.0:8080"]