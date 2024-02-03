# syntax=docker.io/docker/dockerfile:1.6.0

FROM scilpy-base as scilpy

LABEL maintainer=SCIL

ARG BLAS_NUM_THREADS
ARG PYTHON_VERSION
ARG SCILPY_VERSION
ARG VTK_INSTALL_PATH
ARG VTK_VERSION
ARG PYTHON_PACKAGE_DIR

ENV PYTHON_PACKAGE_DIR=${PYTHON_PACKAGE_DIR:-site-packages}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV SCILPY_VERSION=${SCILPY_VERSION:-master}
ENV OPENBLAS_NUM_THREADS=${BLAS_NUM_THREADS:-1}
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        clinfo \
        git \
        libblas-dev \
        libfreetype6-dev \
        liblapack-dev \
        locales \
        python3.10 \
        python3-dev \
        unzip \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen "en_US.UTF-8" && \
    update-locale LANG=en_US.UTF-8

WORKDIR /
ADD https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip scilpy.zip
RUN unzip scilpy.zip && \
    ZIP_NAME=$(echo ${SCILPY_VERSION} | tr / -) && \
    mv scilpy-${ZIP_NAME} scilpy && \
    rm scilpy.zip

WORKDIR /scilpy
RUN SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True python${PYTHON_VERSION} -m pip install -e . && \
    python${PYTHON_VERSION} -m pip install pyopencl==2023.1.3 && \
    python${PYTHON_VERSION} -m pip cache purge

WORKDIR ${VTK_INSTALL_PATH}
RUN python${PYTHON_VERSION} -m pip install vtk-${VTK_VERSION}.dev0-cp310-cp310-linux_x86_64.whl

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/matplotlib/mpl-data/matplotlibrc && \
    cp -r /scilpy/data /usr/local/lib/python${PYTHON_VERSION}/${PYTHON_PACKAGE_DIR}/ && \
    apt-get -y remove \
        git \
        wget \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Scilpy => ${SCILPY_VERSION}\n" >> VERSION
