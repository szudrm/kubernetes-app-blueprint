# check=skip=FromAsCasing
FROM public.ecr.aws/docker/library/python:3.12-slim AS base

RUN useradd --uid 1000 \
            --user-group \
            --home-dir /app \
            --create-home \
            --skel /dev/null \
            --shell /usr/sbin/nologin \
            appuser
USER appuser
WORKDIR /app


FROM base AS build

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY --chown=appuser:appuser app/* ./
ENV PATH=/app/.local/bin:$PATH
RUN pip install --upgrade pip && \
    pip install --user -r requirements.txt && \
    rm -f requirements.txt


FROM base

ARG APP_PORT=8080
ENV APP_PORT=$APP_PORT
ENV PYTHONUNBUFFERED=1

COPY --from=build --chown=root:root --chmod=755 /app /app/

CMD ["python", "main.py"]
