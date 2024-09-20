# syntax=docker.io/docker/dockerfile:1.10.0

FROM cmake-builder AS cmake

ARG CMAKE_BUILD_NTHREADS
ARG CMAKE_REVISION

ENV CMAKE_BUILD_NTHREADS=${CMAKE_BUILD_NTHREADS:-""}
ENV CMAKE_REVISION=${CMAKE_REVISION:-v3.16.3}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        build-essential \
        libssl-dev \
        linux-headers-generic \
        wget && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/Kitware/CMake.git#${CMAKE_REVISION} /cmake

WORKDIR /cmake
RUN ./bootstrap && \
    [ -z "$CMAKE_BUILD_NTHREADS" ] && \
        { make -j $(nproc --all); } || \
        { make -j ${CMAKE_BUILD_NTHREADS}; } && \
    make install

WORKDIR /
RUN rm -rf cmake

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "CMake => ${CMAKE_REVISION}\n" >> VERSION
