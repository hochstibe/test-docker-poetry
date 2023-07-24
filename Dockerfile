FROM python:3.10-slim-buster as python-base

ENV FOLDER="test_docker_poetry" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.5.1 \
    POETRY_HOME="/opt/pipx/venvs/poetry/" \
    POETRY_CACHE_DIR="/opt/poetry/.cache" \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup"
# set the path to poetry
ENV PATH="$POETRY_HOME/bin:$PATH"

RUN buildDeps="build-essential" \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# builder-base is used to build dependencies
FROM python-base as builder-base

# get pipx and install poetry
ENV PIPX_HOME="/opt/pipx" \
    PIX_BIN_DIR="/usr/local/bin"
RUN python3 -m pip install --user pipx
RUN python3 -m pipx ensurepath
RUN python3 -m pipx install "poetry==$POETRY_VERSION"
RUN python3 -m venv $PYSETUP_PATH

WORKDIR /${FOLDER}
# Install the main dependencies
COPY ./poetry.lock ./pyproject.toml ./
RUN chmod +x ./poetry.lock ./pyproject.toml
RUN poetry install --only main --sync --no-directory --no-interaction --no-ansi


# Copying in our entrypoint, activate the environment
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Activate the environment, build the application
ENTRYPOINT /entrypoint.sh $0 $@

CMD ["poetry", "run", "python", "-u", "./test_docker_poetry/main.py"]
