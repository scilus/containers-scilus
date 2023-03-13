# syntax=docker/dockerfile:1.4

FROM scilus-base as scilus

LABEL maintainer=SCIL

ARG FROZEN_REQUIREMENTS
ARG ITK_NUM_THREADS
ARG SCILPY_VERSION

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV VTK_VERSION=${VTK_VERSION:-9.2.6}

ENV FROZEN_REQUIREMENTS=${FROZEN_REQUIREMENTS:-requirements.${SCILPY_VERSION}.frozen}

ENV LC_ALL=C

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        bc \
        git \
        nvidia-cuda-toolkit \
    && rm -rf /var/lib/apt/lists/*

ADD human-data_master_1d3abfb.tar.bz2 /human-data
ADD ${FROZEN_REQUIREMENTS} /tmp/requirements.frozen

WORKDIR /tmp
RUN python${PYTHON_VERSION} -vvv -m pip install -r requirements.frozen && \
    rm requirements.frozen

ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}

WORKDIR ${VTK_INSTALL_PATH}
RUN which python${PYTHON_VERSION} && python${PYTHON_VERSION} -m pip install vtk-${VTK_VERSION}.dev0-cp310-cp310-linux_x86_64.whl

WORKDIR /tests
RUN python3 -m pip install pytest
RUN python3 -m pytest


RUN apt-get -y remove \
        git && \
    apt-get -y autoremove

FROM scilus as scilus-test
ADD tests/ /tests/

WORKDIR /tests
RUN python3 -m pip install pytest
RUN python3 -m pytest
