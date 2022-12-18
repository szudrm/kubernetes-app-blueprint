# check=skip=FromAsCasing
FROM public.ecr.aws/docker/library/python:3.12-slim

RUN useradd --uid 1000 \
            --user-group \
            --home-dir /app \
            --no-create-home \
            --shell /usr/sbin/nologin \
            appuser

WORKDIR /app
RUN chown -R appuser:appuser /app
USER appuser
ENV PATH=/app/.local/bin:$PATH

COPY --chown=appuser:appuser app/* ./
RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir --no-compile -r requirements.txt

ENV APP_PORT=8080
EXPOSE 8080

CMD ["python", "main.py"]
