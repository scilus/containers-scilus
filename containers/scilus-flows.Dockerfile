# syntax=docker.io/docker/dockerfile:1.10.0

FROM flow-base as scilus-flows

ARG TRACTOFLOW_VERSION
ARG DMRIQCFLOW_VERSION
ARG EXTRACTORFLOW_VERSION
ARG RBXFLOW_VERSION
ARG TRACTOMETRYFLOW_VERSION
ARG REGISTERFLOW_VERSION
ARG DISCONETSFLOW_VERSION
ARG FREEWATERFLOW_VERSION
ARG NODDIFLOW_VERSION
ARG BSTFLOW_VERSION

ENV TRACTOFLOW_VERSION=${TRACTOFLOW_VERSION:-2.3.0}
ENV DMRIQCFLOW_VERSION=${DMRIQCFLOW_VERSION:-0.1.0}
ENV EXTRACTORFLOW_VERSION=${EXTRACTORFLOW_VERSION:-master}
ENV RBXFLOW_VERSION=${RBXFLOW_VERSION:-1.1.0}
ENV TRACTOMETRYFLOW_VERSION=${TRACTOMETRYFLOW_VERSION:-1.0.0}
ENV REGISTERFLOW_VERSION=${REGISTERFLOW_VERSION:-main}
ENV DISCONETSFLOW_VERSION=${DISCONETSFLOW_VERSION:-0.1.0-rc1}
ENV FREEWATERFLOW_VERSION=${FREEWATERFLOW_VERSION:-1.0.0}
ENV NODDIFLOW_VERSION=${NODDIFLOW_VERSION:-1.0.0}
ENV BSTFLOW_VERSION=${BSTFLOW_VERSION:-1.0.0-rc1}

WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        rsync \
        unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir scilus_flows

ADD https://github.com/scilus/tractoflow/archive/${TRACTOFLOW_VERSION}.zip /scilus_flows/tractoflow.zip
ADD https://github.com/scilus/dmriqc_flow/archive/${DMRIQCFLOW_VERSION}.zip /scilus_flows/dmriqc-flow.zip
ADD https://github.com/scilus/extractor_flow/archive/${EXTRACTORFLOW_VERSION}.zip /scilus_flows/extractor-flow.zip
ADD https://github.com/scilus/rbx_flow/archive/${RBXFLOW_VERSION}.zip /scilus_flows/rbx-flow.zip
ADD https://github.com/scilus/tractometry_flow/archive/${TRACTOMETRYFLOW_VERSION}.zip /scilus_flows/tractometry-flow.zip
ADD https://github.com/scilus/register_flow/archive/${REGISTERFLOW_VERSION}.zip /scilus_flows/register-flow.zip
ADD https://github.com/scilus/disconets_flow/archive/${DISCONETSFLOW_VERSION}.zip /scilus_flows/disconets-flow.zip
ADD https://github.com/scilus/freewater_flow/archive/${FREEWATERFLOW_VERSION}.zip /scilus_flows/freewater-flow.zip
ADD https://github.com/scilus/noddi_flow/archive/${NODDIFLOW_VERSION}.zip /scilus_flows/noddi-flow.zip
ADD https://github.com/scilus/bst_flow/archive/${BSTFLOW_VERSION}.zip /scilus_flows/bst-flow.zip

WORKDIR /scilus_flows
RUN unzip tractoflow.zip && \
    mv tractoflow-$(echo "${TRACTOFLOW_VERSION}" | tr / -) tractoflow && \
    rm tractoflow.zip

RUN unzip dmriqc-flow.zip && \
    mv dmriqc_flow-$(echo "${DMRIQCFLOW_VERSION}" | tr / -) dmriqc_flow && \
    rm dmriqc-flow.zip

RUN unzip extractor-flow.zip && \
    mv extractor_flow-$(echo "${EXTRACTORFLOW_VERSION}" | tr / -) extractor_flow && \
    rm extractor-flow.zip

RUN unzip rbx-flow.zip && \
    mv rbx_flow-$(echo "${RBXFLOW_VERSION}" | tr / -) rbx_flow && \
    rm rbx-flow.zip

RUN unzip tractometry-flow.zip && \
    mv tractometry_flow-$(echo "${TRACTOMETRYFLOW_VERSION}" | tr / -) tractometry_flow && \
    rm tractometry-flow.zip

RUN unzip register-flow.zip && \
    mv register_flow-$(echo "${REGISTERFLOW_VERSION}" | tr / -) register_flow && \
    rm register-flow.zip

RUN unzip disconets-flow.zip && \
    mv disconets_flow-$(echo "${DISCONETSFLOW_VERSION}" | tr / -) disconets_flow && \
    rm disconets-flow.zip

RUN unzip freewater-flow.zip && \
    mv freewater_flow-$(echo "${FREEWATERFLOW_VERSION}" | tr / -) freewater_flow && \
    rm freewater-flow.zip

RUN unzip noddi-flow.zip && \
    mv noddi_flow-$(echo "${NODDIFLOW_VERSION}" | tr / -) noddi_flow && \
    rm noddi-flow.zip

RUN unzip bst-flow.zip && \
    mv bst_flow-$(echo "${BSTFLOW_VERSION}" | tr / -) bst_flow && \
    rm bst-flow.zip

RUN apt-get -y remove \
        unzip && \
    apt-get -y autoremove

WORKDIR /
RUN mkdir /extractor_flow && \
    tar -jxf /scilus_flows/extractor_flow/containers/templates_and_ROIs.tar.bz2 -C /extractor_flow/ && \
    tar -jxf /scilus_flows/extractor_flow/containers/filtering_lists.tar.bz2 -C /extractor_flow/ && \
    chmod go+rx /extractor_flow

WORKDIR /usr/bin
RUN echo "#!/bin/bash\nnextflow run /scilus_flows/tractoflow/main.nf \$@" >> tractoflow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/dmriqc_flow/main.nf \$@" >> dmriqc-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/extractor_flow/main.nf \$@" >> extractor-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/rbx_flow/main.nf \$@" >> rbx-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/tractometry_flow/main.nf \$@" >> tractometry-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/register_flow/main.nf \$@" >> register-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/disconets_flow/main.nf \$@" >> disconets-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/freewater_flow/main.nf \$@" >> freewater-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/noddi_flow/main.nf \$@" >> noddi-flow && \
    echo "#!/bin/bash\nnextflow run /scilus_flows/bst_flow/main.nf \$@" >> bst-flow && \
    chmod ugo+rx tractoflow \
                 dmriqc-flow \
                 extractor-flow \
                 rbx-flow \
                 tractometry-flow \
                 register-flow \
                 disconets-flow \
                 freewater-flow \
                 noddi-flow \
                 bst-flow

ENV NXF_OFFLINE=true

WORKDIR /
RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "Tractoflow => ${TRACTOFLOW_VERSION}\n" >> VERSION && \
    echo "Dmriqc-flow => ${DMRIQCFLOW_VERSION}\n" >> VERSION && \
    echo "Extractor-flow => ${EXTRACTORFLOW_VERSION}\n" >> VERSION && \
    echo "RBX-flow => ${RBXFLOW_VERSION}\n" >> VERSION && \
    echo "Tractometry-flow => ${TRACTOMETRYFLOW_VERSION}\n" >> VERSION && \
    echo "Register-flow => ${REGISTERFLOW_VERSION}\n" >> VERSION && \
    echo "Disconets-flow => ${DISCONETSFLOW_VERSION}\n" >> VERSION && \
    echo "Freewater-flow => ${FREEWATERFLOW_VERSION}\n" >> VERSION && \
    echo "NODDI-flow => ${NODDIFLOW_VERSION}\n" >> VERSION && \
    echo "BST-flow => ${BSTFLOW_VERSION}\n" >> VERSION
