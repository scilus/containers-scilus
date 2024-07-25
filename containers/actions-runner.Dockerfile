FROM actions-runner-base AS actions-runner

ARG CONTAINER_INSTALL_USER
ARG CONTAINER_RUN_USER

ENV USER=${USER:-0}
ENV CONTAINER_INSTALL_USER=${CONTAINER_INSTALL_USER:-USER}
ENV CONTAINER_RUN_USER=${CONTAINER_RUN_USER:-USER}
ENV DEBIAN_FRONTEND=noninteractive

USER $CONTAINER_INSTALL_USER

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        curl \
        gawk \
        git \
        libfreetype6-dev \
        locales && \
    rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8

USER $CONTAINER_RUN_USER
