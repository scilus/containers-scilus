# syntax=docker/dockerfile:1.4

FROM ants-builder as ants

ARG ANTS_VERSION
ENV ANTS_VERSION=${ANTS_VERSION:-2.3.4}
ARG ANTS_INSTALL_PATH
ENV ANTS_INSTALL_PATH=${ANTS_INSTALL_PATH:-/ants_install}

RUN apt-get update && \
    apt-get -y install \
        git \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN mkdir ants_build && \
    git clone https://github.com/ANTsX/ANTs.git

WORKDIR /ANTs
RUN git fetch --tags && \
    git checkout tags/v${ANTS_VERSION} -b v${ANTS_VERSION}

WORKDIR /ants_build
RUN cmake \
    -DBUILD_SHARED_LIBS=OFF \
    -DUSE_VTK=OFF \
    -DSuperBuild_ANTS_USE_GIT_PROTOCOL=OFF \
    -DBUILD_TESTING=OFF \
    -DRUN_LONG_TESTS=OFF \
    -DRUN_SHORT_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=${ANTS_INSTALL_PATH} \
    ../ANTs && \
    make -j $(nproc --all)

WORKDIR /ants_build/ANTS-build
RUN make install

FROM ants-base as ants-install

ARG ANTS_VERSION
ENV ANTS_VERSION=${ANTS_VERSION:-2.3.4}
ARG ANTS_INSTALL_PATH
ENV ANTS_INSTALL_PATH=${ANTS_INSTALL_PATH:-/opt/ANTs}
ENV ANTSPATH=${ANTS_INSTALL_PATH}/bin/
ENV PATH=$PATH:$ANTSPATH

WORKDIR /
COPY --from=ants ${ANTS_INSTALL_PATH} ${ANTS_INSTALL_PATH}
RUN apt-get update && \
    apt-get -y install \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN touch VERSION && \
    echo "ANTs => ${ANTS_VERSION}\n" >> VERSION