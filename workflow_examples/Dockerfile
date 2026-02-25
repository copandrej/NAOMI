FROM python:3.10-slim-buster

WORKDIR /root
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONPATH=/root

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_PYTHON_DOWNLOADS=never

# Install Python dependencies
COPY requirements.txt /root
RUN uv pip install --system -r /root/requirements.txt

# Installing mltk separately, as it has an incompatible protobuf constraint with flytekit
# This is needed for TinyML example workflows
RUN uv pip install --system --no-deps silabs-mltk[full]==0.19.0

# Copy the actual code
COPY . /root

# This tag is supplied by the build script and will be used to determine the version
# when registering tasks, workflows, and launch plans
ARG tag
ENV FLYTE_INTERNAL_IMAGE=$tag
