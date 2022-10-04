# syntax=docker/dockerfile:1.4

FROM fsl-builder as fsl

ARG FSL_BUILD_INSTALL_PATH
ENV FSL_BUILD_INSTALL_PATH=${FSL_BUILD_INSTALL_PATH:-/fsl_install}
ARG FSL_VERSION
ENV FSL_VERSION=${FSL_VERSION:-6.0.5.2}

RUN apt-get update && \
    apt-get -y install \
        python \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/fsl_sources
WORKDIR /tmp/fsl_sources
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
    python fslinstaller.py \
        -d ${FSL_BUILD_INSTALL_PATH} \
        -V ${FSL_VERSION} \
        -D && \
    rm -rf ${FSL_BUILD_INSTALL_PATH}/src \
           ${FSL_BUILD_INSTALL_PATH}/data \
           ${FSL_BUILD_INSTALL_PATH}/build \
           ${FSL_BUILD_INSTALL_PATH}/include \
           ${FSL_BUILD_INSTALL_PATH}/build.log \
           ${FSL_BUILD_INSTALL_PATH}/tcl \
           ${FSL_BUILD_INSTALL_PATH}/LICENSE \
           ${FSL_BUILD_INSTALL_PATH}/README \
           ${FSL_BUILD_INSTALL_PATH}/refdoc \
           ${FSL_BUILD_INSTALL_PATH}/python \
           ${FSL_BUILD_INSTALL_PATH}/doc \
           ${FSL_BUILD_INSTALL_PATH}/config \
           ${FSL_BUILD_INSTALL_PATH}/fslpython

FROM fsl-base AS fsl-install

ARG FSL_BUILD_INSTALL_PATH=/fsl_install
ARG FSL_INSTALL_PATH
ENV FSL_INSTALL_PATH=${FSL_INSTALL_PATH:-/usr/share/fsl}
ENV FSLDIR=$FSL_INSTALL_PATH
ENV PATH=${FSLDIR}/bin:$PATH
ENV LD_LIBRARY_PATH=${FSLDIR}:${FSLDIR}/bin
ENV FSLBROWSER=/etc/alternatives/x-www-browser
ENV FSLCLUSTER_MAILOPTS=n
ENV FSLMULTIFILEQUIT=TRUE
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV POSSUMDIR=${FSLDIR}

COPY --from=fsl /mrhs/dev/fsl /mrhs/dev/fsl
