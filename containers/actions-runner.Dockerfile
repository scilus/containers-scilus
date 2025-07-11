FROM actions-runner-base AS actions-runner

ARG CONTAINER_INSTALL_USER
ARG CONTAINER_RUN_USER
ARG RUNNER_VERSION
ARG RUNNER_HOOK_VERSION

ENV USER=${USER:-root}
ENV CONTAINER_INSTALL_USER=${CONTAINER_INSTALL_USER:-$USER}
ENV CONTAINER_RUN_USER=${CONTAINER_RUN_USER:-$USER}
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION=${RUNNER_VERSION:-2.319.1}
ENV RUNNER_HOOK_VERSION=${RUNNER_HOOK_VERSION:-0.6.1}

USER $CONTAINER_INSTALL_USER

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        curl \
        gawk \
        git \
        libfreetype6-dev \
        libgl1-mesa-dev \
        libosmesa6-dev \
        locales && \
    rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "runner => ${RUNNER_VERSION}\n" >> VERSION && \
    echo "runner-hook => ${RUNNER_HOOK_VERSION}\n" >> VERSION

USER $CONTAINER_RUN_USER
