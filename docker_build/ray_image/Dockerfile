# Start from the rayproject/2.54.0-py310-aarch64 image for raspberry pi

FROM rayproject/ray:2.54.0-py310

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_PYTHON_DOWNLOADS=never

# Install dependencies from requirements.txt
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# docker build . --tag copandrej/ijs-custom:ray-amd64-ray254
# docker build . --tag copandrej/ijs-custom:ray-aarch64-ray254 # on a raspberry pi