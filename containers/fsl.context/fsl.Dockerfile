# syntax=docker.io/docker/dockerfile:1.5.0

FROM fsl-builder as fsl

ARG FSL_INSTALL_PATH
ARG FSL_VERSION

ENV FSL_INSTALL_PATH=${FSL_INSTALL_PATH:-/fsl}
ENV FSL_VERSION=${FSL_VERSION:-6.0.6.4}
ENV MINICONDA_VERSION=${MINICONDA_VERSION:-22.11.1-4}

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        python-is-python3 \
        wget \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${FSL_INSTALL_PATH}

COPY --link fslinstaller.py /fslinstaller.py
COPY --link fsl_conda_env.yml /fsl_conda_env.yml

RUN python fslinstaller.py \
        -d ${FSL_INSTALL_PATH} \
        -V ${FSL_VERSION} \
        -e /fsl_conda_env.yml \
        -n -o && \
    rm -rf ${FSL_INSTALL_PATH}/cmake \
           ${FSL_INSTALL_PATH}/compiler_compat \
           ${FSL_INSTALL_PATH}/conda-meta \
           ${FSL_INSTALL_PATH}/config \
           ${FSL_INSTALL_PATH}/doc \
           ${FSL_INSTALL_PATH}/docs \
           ${FSL_INSTALL_PATH}/envs \
           ${FSL_INSTALL_PATH}/fonts \
           ${FSL_INSTALL_PATH}/include \
           ${FSL_INSTALL_PATH}/man \
           ${FSL_INSTALL_PATH}/mkspecs \
           ${FSL_INSTALL_PATH}/phrasebooks \
           ${FSL_INSTALL_PATH}/qml \
           ${FSL_INSTALL_PATH}/shell \
           ${FSL_INSTALL_PATH}/src \
           ${FSL_INSTALL_PATH}/tcl \
           ${FSL_INSTALL_PATH}/translations \
           ${FSL_INSTALL_PATH}/var

FROM fsl-base AS fsl-install

ARG FSL_INSTALL_PATH
ARG FSL_VERSION

ENV FSL_INSTALL_PATH=${FSL_INSTALL_PATH:-/fsl}
ENV FSL_VERSION=${FSL_VERSION:-6.0.5.2}

ENV FSLBROWSER=/etc/alternatives/x-www-browser
ENV FSLCLUSTER_MAILOPTS=n
ENV FSLDIR=$FSL_INSTALL_PATH
ENV FSLMULTIFILEQUIT=TRUE
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV LD_LIBRARY_PATH=${FSLDIR}:${FSLDIR}/bin:$LD_LIBRARY_PATH
ENV PATH=${FSLDIR}/share/fsl/bin:$PATH
ENV POSSUMDIR=${FSLDIR}

WORKDIR /
COPY --from=fsl --link ${FSL_INSTALL_PATH} ${FSL_INSTALL_PATH}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
    dc \
    libopenmpi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "FSL => ${FSL_VERSION}\n" >> VERSION
