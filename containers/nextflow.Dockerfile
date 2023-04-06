# syntax=docker/dockerfile:1.4

FROM nextflow-base as nextflow

ARG NEXTFLOW_VERSION
ARG JAVA_VERSION

ENV NEXTFLOW_VERSION=${NEXTFLOW_VERSION:-21.04.3}
ENV JAVA_VERSION=${JAVA_VERSION:-11}

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        openjdk-${JAVA_VERSION}-jre \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /nextflow /.nextflow /work && \
    chmod -R go+rwx /.nextflow /work

ENV NXF_HOME=/nextflow/.nextflow

ADD https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow /nextflow/nextflow

WORKDIR /nextflow
RUN bash nextflow && \
    chmod go+rx nextflow && \
    chmod -R go+rwx .nextflow && \
    mv nextflow /usr/bin/nextflow && \
    apt-get -y autoremove

ENV NXF_OFFLINE=true

VOLUME $NXF_HOME
VOLUME /.nextflow

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Nextflow => ${NEXTFLOW_VERSION}\n" >> VERSION && \
    echo "Java => ${JAVA_VERSION}\n" >> VERSION
