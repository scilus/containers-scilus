# syntax=docker.io/docker/dockerfile:1.6.0

FROM mrtrix-builder as mrtrix

ARG MRTRIX_BUILD_NTHREADS
ARG MRTRIX_REVISION

ENV MRTRIX_BUILD_NTHREADS=${MRTRIX_BUILD_NTHREADS:-""}
ENV MRTRIX_REVISION=${MRTRIX_REVISION:-3.0_RC3}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        build-essential \
        clang \
        git \
        libeigen3-dev \
        libfftw3-dev \
        libomp-dev \
        libpng-dev \
        libtiff5-dev \
        python-is-python3 \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /
ADD https://github.com/MRtrix3/mrtrix3.git#${MRTRIX_REVISION} /mrtrix3

WORKDIR /mrtrix3
RUN git fetch --tags && \
    git checkout tags/${MRTRIX_VERSION} -b ${MRTRIX_VERSION}

RUN ./configure -nogui && \
    [ -z "$MRTRIX_BUILD_NTHREADS" ] && \
        { NUMBER_OF_PROCESSORS=$(nproc --all) ./build; } || \
        { NUMBER_OF_PROCESSORS=${MRTRIX_BUILD_NTHREADS} ./build; } && \
    rm -rf .gitattributes \
           .github \
           .gitignore \
           .gitmodules \
           .readthedocs.yml \
           CONTRIBUTING.md \
           Dockerfile \
           Doxyfile \
           README.md \
           Singularity \
           build \
           build.default.active \
           build.log \
           check_syntax \
           cmd \
           config \
           configure \
           configure.log \
           docs \
           doxygen \
           generate_bash_completion.py \
           icons \
           install_mime_types.sh \
           matlab \
           mrview.desktop \
           package_mrtrix \
           run_pylint \
           run_tests \
           set_path \
           src \
           testing \
           tmp \
           update_copyright \
           update_dev_doc

FROM mrtrix-base as mrtrix-install

ARG MRTRIX_INSTALL_PATH
ARG MRTRIX_REVISION

ENV MRTRIX_INSTALL_PATH=${MRTRIX_INSTALL_PATH:-/mrtrix3_install}
ENV MRTRIX_REVISION=${MRTRIX_REVISION:-3.0_RC3}

ENV PATH=${MRTRIX_INSTALL_PATH}/bin:$PATH

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        libeigen3-dev \
        libfftw3-dev \
        libomp-dev \
        libpng-dev \
        libtiff5-dev \
        python-is-python3 \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=mrtrix --link /mrtrix3 ${MRTRIX_INSTALL_PATH}

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Mrtrix => ${MRTRIX_REVISION}\n" >> VERSION
