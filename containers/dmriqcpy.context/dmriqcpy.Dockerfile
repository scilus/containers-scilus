# syntax=docker.io/docker/dockerfile:1.10.0

FROM dmriqcpy-base as dmriqcpy

LABEL maintainer=SCIL

ARG DMRIQCPY_REVISION
ARG PYTHON_VERSION
ARG PYTHON_PACKAGE_DIR

ENV DMRIQCPY_REVISION=${DMRIQCPY_REVISION:-0.1.6}
ENV PYTHON_PACKAGE_DIR=${PYTHON_PACKAGE_DIR:-site-packages}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

ENV SETUPTOOLS_USE_DISTUTILS=stdlib

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        fonts-freefont-ttf \
        git \
        locales \
        python3.10 \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,sharing=locked,target=/root/.cache/pip \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && locale-gen && \
    python${PYTHON_VERSION} -m pip install \
        git+https://github.com/scilus/dmriqcpy.git@${DMRIQCPY_REVISION} && \
    python${PYTHON_VERSION} -m pip cache purge && \
    sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/matplotlib/mpl-data/matplotlibrc && \
    apt-get -y remove git && \
    apt-get -y autoremove

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "dMRIqcpy => ${DMRIQCPY_REVISION}\n" >> VERSION
