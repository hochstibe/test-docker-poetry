set -e

poetry show
poetry install --only extensions -vvv
poetry show
