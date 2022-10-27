# syntax=docker/dockerfile:1.4

FROM scilpy-base as scilpy

ARG BLAS_NUM_THREADS
ARG PYTHON_VERSION
ARG SCILPY_VERSION

ENV PYTHON_PACKAGE_DIR=${PYTHON_PACKAGE_DIR:-dist-package}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.7}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
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
RUN python${PYTHON_VERSION} -m pip install -e . && \
    python${PYTHON_VERSION} -m pip cache purge

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/matplotlib/mpl-data/matplotlibrc && \
    cp -r /scilpy/data /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/ && \
    apt-get -y remove \
        wget \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN touch VERSION && \
    echo "Scilpy => ${SCILPY_VERSION}\n" >> VERSION
