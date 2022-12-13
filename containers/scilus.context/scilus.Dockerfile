# syntax=docker/dockerfile:1.4

FROM --platform=$TARGETPLATFORM scilus-base as scilus

LABEL maintainer=SCIL

ARG FROZEN_REQUIREMENTS
ARG ITK_NUM_THREADS
ARG PYTHON_VERSION
ARG SCILPY_VERSION

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.7}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}

ENV FROZEN_REQUIREMENTS=${FROZEN_REQUIREMENTS:-requirements.${SCILPY_VERSION}.frozen}

ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data
ADD ${FROZEN_REQUIREMENTS} /tmp/requirements.frozen

WORKDIR /tmp
RUN python${PYTHON_VERSION} -m pip install --no-cache-dir -r requirements.frozen && \
    rm requirements.frozen

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
    bc \
    nvidia-cuda-toolkit \
    && rm -rf /var/lib/apt/lists/*

FROM --platform=$TARGETPLATFORM scilus as scilus-test
ADD tests/ /tests/

ARG PYTHON_VERSION

ENV PYTHON_VERSION=${PYTHON_VERSION:-3.7}

WORKDIR /tests
RUN python${PYTHON_VERSION} -m pip install --no-cache-dir pytest
RUN python${PYTHON_VERSION} -m pytest
