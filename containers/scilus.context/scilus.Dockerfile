# syntax=docker.io/docker/dockerfile:1.10.0

FROM scilus-base as scilus

LABEL maintainer=SCIL

ARG ITK_NUM_THREADS
ARG SCILPY_VERSION

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}

ENV NVIDIA_DISABLE_REQUIRE=1

ADD --link --chmod=666 human-data_master_1d3abfb.tar.bz2 /human-data

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        bc \
        git \
        jq \
        less \
        locales \
        unzip \
        wget \
        imagemagick \
    && rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

# Set up Numba cache
# https://github.com/numba/numba/issues/4032
WORKDIR /
ENV NUMBA_CACHE_DIR=/numba_cache
RUN mkdir $NUMBA_CACHE_DIR && chmod 777 $NUMBA_CACHE_DIR

WORKDIR /tmp
RUN wget https://github.com/scilus/scilpy/releases/download/${SCILPY_VERSION}/requirements.${SCILPY_VERSION}.frozen; \
    exit 0
RUN --mount=type=cache,sharing=locked,target=/root/.cache/pip \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && locale-gen && \
    if [ -f requirements.${SCILPY_VERSION}.frozen ]; \
    then \
        python${PYTHON_VERSION} -m pip install -r requirements.${SCILPY_VERSION}.frozen && \
        rm requirements.${SCILPY_VERSION}.frozen; \
    fi

WORKDIR /
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN apt-get -y remove \
        git && \
    apt-get -y autoremove
