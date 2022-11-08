# syntax=docker/dockerfile:1.4

FROM fsl-builder as fsl

ARG FSL_INSTALL_PATH
ARG FSL_VERSION

ENV FSL_INSTALL_PATH=${FSL_INSTALL_PATH:-/fsl}
ENV FSL_VERSION=${FSL_VERSION:-6.0.5.2}

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        python \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/fsl_sources
WORKDIR /tmp/fsl_sources
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
    python fslinstaller.py \
        -d ${FSL_INSTALL_PATH} \
        -V ${FSL_VERSION} \
        -D && \
    rm -rf ${FSL_INSTALL_PATH}/src \
           ${FSL_INSTALL_PATH}/data \
           ${FSL_INSTALL_PATH}/build \
           ${FSL_INSTALL_PATH}/include \
           ${FSL_INSTALL_PATH}/build.log \
           ${FSL_INSTALL_PATH}/tcl \
           ${FSL_INSTALL_PATH}/LICENSE \
           ${FSL_INSTALL_PATH}/README \
           ${FSL_INSTALL_PATH}/refdoc \
           ${FSL_INSTALL_PATH}/python \
           ${FSL_INSTALL_PATH}/doc \
           ${FSL_INSTALL_PATH}/config \
           ${FSL_INSTALL_PATH}/fslpython

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
ENV LD_LIBRARY_PATH=${FSLDIR}:${FSLDIR}/bin
ENV PATH=${FSLDIR}/bin:$PATH
ENV POSSUMDIR=${FSLDIR}

WORKDIR /
COPY --from=fsl --link ${FSL_INSTALL_PATH} ${FSL_INSTALL_PATH}
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        libopenmpi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN touch VERSION && \
    echo "FSL => ${FSL_VERSION}\n" >> VERSION
