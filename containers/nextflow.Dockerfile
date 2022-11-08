FROM nextflow-base as nextflow

ARG NEXTFLOW_VERSION
ARG JAVA_VERSION

ENV NEXTFLOW_VERSION=${NEXTFLOW_VERSION:-21.04.3}
ENV JAVA_VERSION=${JAVA_VERSION:-11}

WORKDIR /
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        openjdk-${JAVA_VERSION}-jre \
        wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO- https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/bin/nextflow && \
    apt-get -y remove \
        wget && \
    apt-get -y autoremove

WORKDIR /
RUN touch VERSION && \
    echo "Nextflow => ${NEXTFLOW_VERSION}\n" >> VERSION && \
    echo "Java => ${JAVA_VERSION}\n" >> VERSION
