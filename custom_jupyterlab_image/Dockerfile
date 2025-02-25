# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/base-notebook:lab-3.6.3
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

# Create alternative for nano -> nano-tiny
RUN update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

# install python packages
RUN pip install \
    ipywidgets \
    jupyterlab-code-formatter \
    black \
    isort \
    fastapi \
    matplotlib \
    pandas \
    pydantic \
    rdflib \
    requests \
    seaborn \
    SPARQLWrapper \
    uvicorn \
    jupyterlab-git

# Add R mimetype option to specify how the plot returns from R to the browser
#COPY --chown=${NB_UID}:${NB_GID} Rprofile.site /opt/conda/lib/R/etc/
