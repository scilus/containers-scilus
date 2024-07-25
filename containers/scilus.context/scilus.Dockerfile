# syntax=docker.io/docker/dockerfile:1.5.0

FROM alpine as scilus-staging

ADD --chmod=666 human-data_master_1d3abfb.tar.bz2 /human-data

FROM scilus-base as scilus

LABEL maintainer=SCIL

ARG ITK_NUM_THREADS
ARG SCILPY_VERSION

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=${ITK_NUM_THREADS:-8}
ENV OPENBLAS_NUM_THREADS=${OPENBLAS_NUM_THREADS:-1}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}

ENV NVIDIA_DISABLE_REQUIRE=1

COPY --from=scilus-staging --link /human-data /human-data

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        bc \
        git \
        locales \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8

WORKDIR /tmp
RUN wget https://github.com/scilus/scilpy/releases/download/${SCILPY_VERSION}/requirements.${SCILPY_VERSION}.frozen; \
    exit 0
RUN if [ -f requirements.${SCILPY_VERSION}.frozen ]; \
    then \
        python${PYTHON_VERSION} -m pip install -r requirements.${SCILPY_VERSION}.frozen && \
        rm requirements.${SCILPY_VERSION}.frozen; \
        cd ${VTK_INSTALL_PATH}; \
        python${PYTHON_VERSION} -m pip install vtk-${VTK_VERSION}.dev0-cp310-cp310-linux_x86_64.whl; \
    fi

WORKDIR /
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN apt-get -y remove \
        git && \
    apt-get -y autoremove

WORKDIR /
