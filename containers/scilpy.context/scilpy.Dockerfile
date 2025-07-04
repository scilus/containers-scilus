# syntax=docker.io/docker/dockerfile:1.10.0

FROM scilpy-base AS scilpy

LABEL maintainer=SCIL

ARG BLAS_NUM_THREADS
ARG PYTHON_VERSION
ARG SCILPY_REVISION
ARG VTK_VERSION

ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV SCILPY_REVISION=${SCILPY_REVISION:-master}
ENV OPENBLAS_NUM_THREADS=${BLAS_NUM_THREADS:-1}
ENV VTK_VERSION=${VTK_VERSION:-9.2.6}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

ENV SETUPTOOLS_USE_DISTUTILS=stdlib

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
        python3-pip \
        unzip \
        wget && \
    rm -rf /var/lib/apt/lists/*


ADD --link https://github.com/scilus/scilpy.git#${SCILPY_REVISION} /scilpy

WORKDIR /scilpy
RUN --mount=type=cache,sharing=locked,target=/root/.cache/pip \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && locale-gen && \
    python${PYTHON_VERSION} -m pip install "packaging<22.0" "setuptools<=70.0" && \
    SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True python${PYTHON_VERSION} -m pip install \
        pyopencl==2023.1.3 torch==2.1.2 -e . && \
    python${PYTHON_VERSION} -m pip install --extra-index-url https://wheels.vtk.org vtk[omesa]==$VTK_VERSION && \
    python${PYTHON_VERSION} -m pip cache purge

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/dist-packages/matplotlib/mpl-data/matplotlibrc && \
    cp -r /scilpy/data /usr/local/lib/python${PYTHON_VERSION}/dist-packages/ && \
    apt-get -y remove \
        git \
        wget \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Scilpy => ${SCILPY_REVISION}\n" >> VERSION
