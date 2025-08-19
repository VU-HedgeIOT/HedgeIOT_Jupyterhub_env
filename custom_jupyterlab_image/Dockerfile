# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/base-notebook:lab-4.4.6
FROM $BASE_CONTAINER

LABEL maintainer="Mateusz Kedzia <mateusz.kedzia@gmail.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common useful utilities
    git \
    gh \
    nano-tiny \
    tzdata \
    unzip \
    vim-tiny \
    # git-over-ssh \
    openssh-client \
    # less is needed to run help in R
    # see: https://github.com/jupyter/docker-stacks/issues/1588
    less \
    # nbconvert dependencies
    # https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex
    # Enable clipboard on Linux host systems
    xclip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv 

# Configure uv to use system Python (no venv creation)
ENV UV_SYSTEM_PYTHON=1

# Create alternative for nano -> nano-tiny
RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

# Copy requirements file for better Docker layer caching
COPY --chown=${NB_UID}:${NB_GID} requirements.txt .

# Install python packages using uv (will use system Python due to ENV var)
RUN uv pip install -r requirements.txt

# Add R mimetype option to specify how the plot returns from R to the browser
#COPY --chown=${NB_UID}:${NB_GID} Rprofile.site /opt/conda/lib/R/etc/
