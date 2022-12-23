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

COPY --chown=appuser:appuser app/* ./
ENV PATH=/app/.local/bin:$PATH
RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir --no-compile -r requirements.txt && \
    rm -f requirements.txt

FROM base

COPY --from=build --chown=root:root --chmod=755 /app /app/

ENV APP_PORT=8080
EXPOSE 8080

CMD ["python", "main.py"]
