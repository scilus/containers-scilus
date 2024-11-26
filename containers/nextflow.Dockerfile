# syntax=docker.io/docker/dockerfile:1.10.0

FROM nextflow-base as nextflow

ARG NEXTFLOW_VERSION
ARG JAVA_VERSION

ENV NEXTFLOW_VERSION=${NEXTFLOW_VERSION:-21.04.3}
ENV JAVA_VERSION=${JAVA_VERSION:-11}
ENV NXF_HOME=/nextflow/.nextflow

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        openjdk-${JAVA_VERSION}-jre-headless \
        wget && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /nextflow/.nextflow/plugins && \
    chmod -R ugo+rx /nextflow

ADD --link https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow-${NEXTFLOW_VERSION}-all /nextflow/nextflow

WORKDIR /nextflow
RUN bash nextflow && \
    chmod ugo+rx nextflow && \
    chmod -R ugo+rx .nextflow && \
    mv nextflow /usr/bin/nextflow && \
    apt-get -y autoremove

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Nextflow => ${NEXTFLOW_VERSION}\n" >> VERSION && \
    echo "Java => ${JAVA_VERSION}\n" >> VERSION
