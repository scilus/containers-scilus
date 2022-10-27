# syntax=docker/dockerfile:1.4

FROM cmake-builder AS cmake

ARG CMAKE_VERSION

ENV CMAKE_VERSION=${CMAKE_VERSION:-3.16.3}

RUN apt-get update && \
    apt-get -y install \
        build-essential \
        libssl-dev \
        linux-headers-generic \
        wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN mkdir -p cmake

WORKDIR /tmp/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar -xzf cmake-${CMAKE_VERSION}.tar.gz

WORKDIR /tmp/cmake/cmake-${CMAKE_VERSION}
RUN ./bootstrap && \
    make -j $(nproc --all) && \
    make install

WORKDIR /tmp
RUN rm -rf cmake

WORKDIR /
RUN touch VERSION && \
    echo "CMake => ${CMAKE_VERSION}\n" >> VERSION
