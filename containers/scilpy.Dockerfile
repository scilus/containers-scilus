# syntax=docker/dockerfile:1.4

FROM scilpy-base as scilpy

ARG SCILPY_VERSION
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
ARG BLAS_NUM_THREADS
ENV OPENBLAS_NUM_THREADS=${BLAS_NUM_THREADS:-1}

WORKDIR /
RUN apt-get update && \
    apt-get install -y \
        libblas-dev \
        libfreetype6-dev \
        liblapack-dev \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN wget https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip && \
    unzip ${SCILPY_VERSION}.zip && \
    mv scilpy-${SCILPY_VERSION} scilpy && \
    rm ${SCILPY_VERSION}.zip

WORKDIR /scilpy
RUN pip install -e .

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc && \
    cp -r /scilpy/data /usr/local/lib/python3.7/dist-packages/ && \
    apt-get -y remove \
        wget \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN touch VERSION && \
    echo "Scilpy => ${SCILPY_VERSION}\n" >> VERSION
