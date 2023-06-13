# syntax=docker/dockerfile:1.4

FROM dmriqcpy-base as dmriqcpy

LABEL maintainer=SCIL

ARG DMRIQCPY_VERSION
ARG PYTHON_VERSION
ARG VTK_INSTALL_PATH
ARG VTK_VERSION
ARG PYTHON_PACKAGE_DIR

ENV DMRIQCPY_VERSION=${DMRIQCPY_VERSION:-0.1.6}
ENV PYTHON_PACKAGE_DIR=${PYTHON_PACKAGE_DIR:-site-packages}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        fonts-freefont-ttf \
        git \
        locales \
        python3.10 \
        python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN python${PYTHON_VERSION} -m pip install \
        git+https://github.com/scilus/dmriqcpy.git@${DMRIQCPY_VERSION} && \
    python${PYTHON_VERSION} -m pip cache purge && \
    sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/matplotlib/mpl-data/matplotlibrc && \
    apt-get -y remove git && \
    apt-get -y autoremove

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "dMRIqcpy => ${DMRIQCPY_VERSION}\n" >> VERSION


FROM dmriqcpy as dmriqcpy-test
ADD tests/ /tests/

WORKDIR /tests
RUN python3 -m pip install dipy pytest pytest_console_scripts
RUN python3 -m pytest --script-launch-mode=subprocess
