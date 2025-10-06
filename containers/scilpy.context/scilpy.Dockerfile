# syntax=docker.io/docker/dockerfile:1.10.0

FROM scilpy-base AS scilpy

LABEL maintainer=SCIL

ARG BLAS_NUM_THREADS
ARG PYTHON_VERSION
ARG SCILPY_REVISION
ARG VTK_VERSION
ARG UV_VERSION
ARG PYOPENCL_COMPILER_OUTPUT
ARG GPU

ENV PYTHON_VERSION=${PYTHON_VERSION:-3.10}
ENV UV_VERSION=${UV_VERSION:-0.8.17}
ENV SCILPY_REVISION=${SCILPY_REVISION:-master}
ENV OPENBLAS_NUM_THREADS=${BLAS_NUM_THREADS:-1}
ENV VTK_VERSION=${VTK_VERSION:-9.2.6}
ENV GPU=${GPU:-False}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV PYOPENCL_COMPILER_OUTPUT="1"

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        clinfo \
        git \
        libblas-dev \
        libgl1-mesa-dev \
        libfreetype6-dev \
        liblapack-dev \
        libosmesa6-dev \
        locales \
        python3.12 \
        python3-dev \
        python3-pip \
        unzip \
        imagemagick \
        parallel \
        tmux \
        jq \
        wget && \
    rm -rf /var/lib/apt/lists/*

ADD --link https://github.com/scilus/scilpy.git#${SCILPY_REVISION} /scilpy

# Run the installer then remove it
ADD https://astral.sh/uv/${UV_VERSION}/install.sh /uv-installer.sh

# Run the installer then remove it
RUN UV_INSTALL_DIR=/opt/bin/ sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/opt/bin/:$PATH"

RUN uv venv /opt/venvs/scilpy --python ${PYTHON_VERSION}

# Activate the environment
ENV PATH="/opt/venvs/scilpy/bin:$PATH"

WORKDIR /scilpy
RUN --mount=type=cache,sharing=locked,target=/root/.cache/pip \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && locale-gen && \
    uv pip install "packaging<22.0" "setuptools<=70.0" && \
    uv pip install pyopencl==2023.1.3

RUN if [ "$GPU" = "true" ] ; then \
    uv pip install torch==2.2.*; \
else \
    uv pip install torch==2.2.* --index-url https://download.pytorch.org/whl/cpu; \
fi

RUN uv pip install -e . && \
    uv pip install --extra-index-url https://wheels.vtk.org vtk-osmesa==$VTK_VERSION && \
    pip cache purge

#RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/dist-packages/matplotlib/mpl-data/matplotlibrc && \
RUN cp -r /scilpy/src/scilpy/data /usr/local/lib/python${PYTHON_VERSION}/dist-packages/ && \
    apt-get -y remove \
        git \
        wget \
        curl \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Set up Numba cache
# https://github.com/numba/numba/issues/4032
WORKDIR /
ENV NUMBA_CACHE_DIR=/tmp

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Scilpy => ${SCILPY_REVISION}\n" >> VERSION
