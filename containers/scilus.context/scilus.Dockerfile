# syntax=docker/dockerfile:1.4

FROM scilus-base as scilus

ARG ITK_NUM_THREADS

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}

ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data
ADD requirements.txt.frozen /tmp/requirements.txt.frozen

WORKDIR /tmp
RUN python3 -m pip install -r requirements.txt.frozen && \
    rm requirements.txt.frozen

FROM scilus as scilus-test
ADD tests/ /tests/

WORKDIR /tests
RUN python3 -m pip install pytest
RUN python3 -m pytest
