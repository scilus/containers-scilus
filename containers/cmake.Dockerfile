# syntax=docker.io/docker/dockerfile:1.5.0

FROM cmake-builder AS cmake

ARG CMAKE_BUILD_NTHREADS
ARG CMAKE_VERSION

ENV CMAKE_BUILD_NTHREADS=${CMAKE_BUILD_NTHREADS:-""}
ENV CMAKE_VERSION=${CMAKE_VERSION:-3.16.3}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        build-essential \
        libssl-dev \
        linux-headers-generic \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN mkdir -p cmake

WORKDIR /tmp/cmake
ADD https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz cmake.tar.gz
RUN tar -xzf cmake.tar.gz

WORKDIR /tmp/cmake/cmake-${CMAKE_VERSION}
RUN ./bootstrap && \
    [ -z "$CMAKE_BUILD_NTHREADS" ] && \
        { make -j $(nproc --all); } || \
        { make -j ${CMAKE_BUILD_NTHREADS}; } && \
    make install

WORKDIR /tmp
RUN rm -rf cmake

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "CMake => ${CMAKE_VERSION}\n" >> VERSION
