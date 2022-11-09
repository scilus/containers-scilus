# syntax=docker/dockerfile:1.4

FROM scilus-base as scilus

ARG ITK_NUM_THREADS

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}

ENV LC_ALL=C

ADD --link human-data_master_1d3abfb.tar.bz2 /human-data
ADD --link requirements.txt.frozen /tmp/requirements.txt.frozen

WORKDIR /tmp
RUN python3 -m pip install -r requirements.txt.frozen && \
    rm requirements.txt.frozen

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
    bc \
    && rm -rf /var/lib/apt/lists/*

FROM scilus as scilus-test
ADD --link tests/ /tests/

WORKDIR /tests
RUN python3 -m pip install pytest
RUN python3 -m pytest
