# syntax=docker.io/docker/dockerfile:1.10.0

FROM ants-builder as ants

ARG ANTS_BUILD_NTHREADS
ARG ANTS_INSTALL_PATH
ARG ANTS_REVISION

ENV ANTS_BUILD_NTHREADS=${ANTS_BUILD_NTHREADS:-""}
ENV ANTS_INSTALL_PATH=${ANTS_INSTALL_PATH:-/ants}
ENV ANTS_REVISION=${ANTS_REVISION:-v2.3.4}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        git \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
ADD --link https://github.com/ANTsX/ANTs.git#${ANTS_REVISION} /ants_build


WORKDIR /ants_build
RUN mkdir build

WORKDIR /ants_build/build
RUN cmake -DBUILD_SHARED_LIBS=OFF \
          -DUSE_VTK=OFF \
          -DSuperBuild_ANTS_USE_GIT_PROTOCOL=OFF \
          -DBUILD_TESTING=OFF \
          -DRUN_LONG_TESTS=OFF \
          -DRUN_SHORT_TESTS=OFF \
          -DSuperBuild_ANTS_C_OPTIMIZATION_FLAGS="-mtune=native -march=x86-64" \
          -DSuperBuild_ANTS_CXX_OPTIMIZATION_FLAGS="-mtune=native -march=x86-64" \
          -DCMAKE_INSTALL_PREFIX=${ANTS_INSTALL_PATH} \
          .. && \
    [ -z "$ANTS_BUILD_NTHREADS" ] && \
        { make -j $(nproc --all); } || \
        { make -j ${ANTS_BUILD_NTHREADS}; }

WORKDIR /ants_build/build/ANTS-build
RUN make install

FROM ants-base as ants-install

ARG ANTS_INSTALL_PATH
ARG ANTS_REVISION

ENV ANTS_INSTALL_PATH=${ANTS_INSTALL_PATH:-/ants}
ENV ANTS_REVISION=${ANTS_REVISION:-v2.3.4}

ENV ANTSPATH=${ANTS_INSTALL_PATH}/bin/
ENV PATH=$PATH:$ANTSPATH

COPY --from=ants --link ${ANTS_INSTALL_PATH} ${ANTS_INSTALL_PATH}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "ANTs => ${ANTS_REVISION}\n" >> VERSION
