# syntax=docker.io/docker/dockerfile:1.10.0


FROM fsl-builder as fsl

ARG FSL_INSTALL_PATH
ARG FSL_VERSION
ARG FSL_INSTALLER_VERSION

ENV FSL_INSTALL_PATH=${FSL_INSTALL_PATH:-/fsl}
ENV FSL_VERSION=${FSL_VERSION:-6.0.6.4}
ENV FSL_INSTALLER_VERSION=${FSL_INSTALLER_VERSION:-3.14.0}
ENV MINICONDA_VERSION=${MINICONDA_VERSION:-22.11.1-4}

ENV LC_CTYPE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        locales \
        python-is-python3 \
        wget \
        git \
    && rm -rf /var/lib/apt/lists/*

ADD --link https://git.fmrib.ox.ac.uk/fsl/conda/installer/-/raw/${FSL_INSTALLER_VERSION}/fsl/installer/fslinstaller.py /fsl_build/fslinstaller.py

WORKDIR /fsl_build
RUN --mount=type=bind,source=./manifest.json,target=/fsl_build/manifest.json \
    --mount=type=cache,sharing=locked,target=/root/.cache/pip \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && locale-gen && \
    python fslinstaller.py \
        -d ${FSL_INSTALL_PATH} \
        -V ${FSL_VERSION} \
        --manifest manifest.json \
        -n -o || (cd /root && cat $(ls | grep fsl_installation) && exit 1) && \
    rm -rf ${FSL_INSTALL_PATH}/cmake \
        ${FSL_INSTALL_PATH}/compiler_compat \
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
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${FSLDIR}:${FSLDIR}/bin
ENV PATH=${FSLDIR}/share/fsl/bin:$PATH
ENV POSSUMDIR=${FSLDIR}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        dc \
    && rm -rf /var/lib/apt/lists/*

COPY --from=fsl --link ${FSL_INSTALL_PATH} ${FSL_INSTALL_PATH}

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "FSL => ${FSL_VERSION}\n" >> VERSION
