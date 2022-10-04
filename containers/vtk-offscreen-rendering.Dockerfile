# syntax=docker/dockerfile:1.4

FROM vtk-builder as vtk

ARG MESA_VERSION
ARG VTK_VERSION
ENV MESA_VERSION=${MESA_VERSION:-19.0.8}
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}

RUN mkdir /VTK-src /VTK-build && \
    apt-get update && \
    apt-get -y install \
        build-essential \
        gcc \
        llvm-7 \
        llvm-7-dev \
        llvm-7-runtime \
        clang \
        wget \
        xorg-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN wget https://archive.mesa3d.org/mesa-${MESA_VERSION}.tar.gz && \
    tar -xzf mesa-${MESA_VERSION}.tar.gz && \
    rm mesa-${MESA_VERSION}.tar.gz

FROM vtk-base as vtk-install

ARG MESA_VERSION
ENV MESA_VERSION=${MESA_VERSION:-19.0.8}

WORKDIR /
RUN mkdir test_mesa
COPY --from=vtk /mesa-${MESA_VERSION} /test_mesa/
