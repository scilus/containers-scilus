# syntax=docker/dockerfile:1.4

FROM scilus-base as scilus

ARG ITK_NUM_THREADS
ARG SCILPY_VERSION

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}

ENV FROZEN_REQUIREMENTS=${FROZEN_REQUIREMENTS:-requirements.${SCILPY_VERSION}.frozen}

ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data
ADD ${FROZEN_REQUIREMENTS} /tmp/requirements.frozen

WORKDIR /tmp
RUN python3 -m pip install -r requirements.frozen && \
    rm requirements.frozen

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
    bc \
    && rm -rf /var/lib/apt/lists/*

FROM scilus as scilus-test
ADD tests/ /tests/

WORKDIR /tests
RUN python3 -m pip install pytest
RUN python3 -m pytest
