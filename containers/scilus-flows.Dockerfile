FROM flow-base as scilus-flows

ARG TRACTOFLOW_VERSION
ARG DMRIQCFLOW_VERSION
ARG EXTRACTORFLOW_VERSION
ARG RBXFLOW_VERSION
ARG TRACTOMETRYFLOW_VERSION
ARG REGISTERFLOW_VERSION
ARG DISCONETSFLOW_VERSION
ARG FREESURFERFLOW_VERSION
ARG DISCONNECTFLOW_VERSION
ARG FREEWATERFLOW_VERSION
ARG NODDIFLOW_VERSION
ARG CONVERTSETFLOW_VERSION
ARG REGISTRATIONFLOW_VERSION
ARG BSTFLOW_VERSION

ENV TRACTOFLOW_VERSION=${TRACTOFLOW_VERSION:-2.3.0}
ENV DMRIQCFLOW_VERSION=${DMRIQCFLOW_VERSION:-0.1.0}
ENV EXTRACTORFLOW_VERSION=${EXTRACTORFLOW_VERSION:-master}
ENV RBXFLOW_VERSION=${RBXFLOW_VERSION:-1.1.0}
ENV TRACTOMETRYFLOW_VERSION=${TRACTOMETRYFLOW_VERSION:-1.0.0}
ENV REGISTERFLOW_VERSION=${REGISTERFLOW_VERSION:-master}
ENV DISCONETSFLOW_VERSION=${DISCONETSFLOW_VERSION:-0.1.0-rc1}
ENV FREESURFERFLOW_VERSION=${FREESURFERFLOW_VERSION:-master}
ENV DISCONNECTFLOW_VERSION=${DISCONNECTFLOW_VERSION:-master}
ENV FREEWATERFLOW_VERSION=${FREEWATERFLOW_VERSION:-1.0.0}
ENV NODDIFLOW_VERSION=${NODDIFLOW_VERSION:-1.0.0}
ENV CONVERTSETFLOW_VERSION=${CONVERTSETFLOW_VERSION:-master}
ENV REGISTRATIONFLOW_VERSION=${REGISTRATIONFLOW_VERSION:-1.0.0}
ENV BSTFLOW_VERSION=${BSTFLOW_VERSION:-1.0.0-rc1}


WORKDIR /
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update && apt-get -y install \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir scilus_flows

WORKDIR /scilus_flows
RUN wget https://github.com/scilus/tractoflow/archive/${TRACTOFLOW_VERSION}.zip && \
    unzip ${TRACTOFLOW_VERSION}.zip && \
    mv tractoflow-${TRACTOFLOW_VERSION} tractoflow && \
    rm ${TRACTOFLOW_VERSION}.zip

RUN wget https://github.com/scilus/dmriqc_flow/archive/${DMRIQCFLOW_VERSION}.zip && \
    unzip ${DMRIQCFLOW_VERSION}.zip && \
    mv dmriqc_flow-${DMRIQCFLOW_VERSION} dmriqc_flow && \
    rm ${DMRIQCFLOW_VERSION}.zip

RUN wget https://github.com/scilus/extractor_flow/archive/${EXTRACTORFLOW_VERSION}.zip && \
    unzip ${EXTRACTORFLOW_VERSION}.zip && \
    mv extractor_flow-${EXTRACTORFLOW_VERSION} extractor_flow && \
    rm ${EXTRACTORFLOW_VERSION}.zip

RUN wget https://github.com/scilus/rbx_flow/archive/${RBXFLOW_VERSION}.zip && \
    unzip ${RBXFLOW_VERSION}.zip && \
    mv rbx_flow-${RBXFLOW_VERSION} rbx_flow && \
    rm ${RBXFLOW_VERSION}.zip

RUN wget https://github.com/scilus/tractometry_flow/archive/${TRACTOMETRYFLOW_VERSION}.zip && \
    unzip ${TRACTOMETRYFLOW_VERSION}.zip && \
    mv tractometry_flow-${TRACTOMETRYFLOW_VERSION} tractometry_flow && \
    rm ${TRACTOMETRYFLOW_VERSION}.zip

RUN wget https://github.com/scilus/register_flow/archive/${REGISTERFLOW_VERSION}.zip && \
    unzip ${REGISTERFLOW_VERSION}.zip && \
    mv register_flow-${REGISTERFLOW_VERSION} register_flow && \
    rm ${REGISTERFLOW_VERSION}.zip

RUN wget https://github.com/scilus/disconets_flow/archive/${DISCONETSFLOW_VERSION}.zip && \
    unzip ${DISCONETSFLOW_VERSION}.zip && \
    mv disconets_flow-${DISCONETSFLOW_VERSION} disconets_flow && \
    rm ${DISCONETSFLOW_VERSION}.zip

RUN wget https://github.com/scilus/freesurfer_flow/archive/${FREESURFERFLOW_VERSION}.zip && \
    unzip ${FREESURFERFLOW_VERSION}.zip && \
    mv freesurfer_flow-${FREESURFERFLOW_VERSION} freesurfer_flow && \
    rm ${FREESURFERFLOW_VERSION}.zip

RUN wget https://github.com/scilus/disconnect_flow/archive/${DISCONNECTFLOW_VERSION}.zip && \
    unzip ${DISCONNECTFLOW_VERSION}.zip && \
    mv disconnect_flow-${DISCONNECTFLOW_VERSION} disconnect_flow && \
    rm ${DISCONNECTFLOW_VERSION}.zip

RUN wget https://github.com/scilus/freewater_flow/archive/${FREEWATERFLOW_VERSION}.zip && \
    unzip ${FREEWATERFLOW_VERSION}.zip && \
    mv freewater_flow-${FREEWATERFLOW_VERSION} freewater_flow && \
    rm ${FREEWATERFLOW_VERSION}.zip

RUN wget https://github.com/scilus/noddi_flow/archive/${NODDIFLOW_VERSION}.zip && \
    unzip ${NODDIFLOW_VERSION}.zip && \
    mv noddi_flow-${NODDIFLOW_VERSION} noddi_flow && \
    rm ${NODDIFLOW_VERSION}.zip

RUN wget https://github.com/scilus/convert_set_flow/archive/${CONVERTSETFLOW_VERSION}.zip && \
    unzip ${CONVERTSETFLOW_VERSION}.zip && \
    mv convert_set_flow-${CONVERTSETFLOW_VERSION} convert_set_flow && \
    rm ${CONVERTSETFLOW_VERSION}.zip

RUN wget https://github.com/scilus/registration_flow/archive/${REGISTRATIONFLOW_VERSION}.zip && \
    unzip ${REGISTRATIONFLOW_VERSION}.zip && \
    mv registration_flow-${REGISTRATIONFLOW_VERSION} registration_flow && \
    rm ${REGISTRATIONFLOW_VERSION}.zip

RUN wget https://github.com/scilus/bst_flow/archive/${BSTFLOW_VERSION}.zip && \
    unzip ${BSTFLOW_VERSION}.zip && \
    mv bst_flow-${BSTFLOW_VERSION} bst_flow && \
    rm ${BSTFLOW_VERSION}.zip

WORKDIR /
RUN touch VERSION && \
    echo "Tractoflow => ${TRACTOFLOW_VERSION}\n" >> VERSION && \
    echo "Dmriqc-flow => ${DMRIQCFLOW_VERSION}\n" >> VERSION && \
    echo "Extractor-flow => ${EXTRACTORFLOW_VERSION}\n" >> VERSION && \
    echo "RBX-flow => ${RBXFLOW_VERSION}\n" >> VERSION && \
    echo "Tractometry-flow => ${TRACTOMETRYFLOW_VERSION}\n" >> VERSION && \
    echo "Register-flow => ${REGISTERFLOW_VERSION}\n" >> VERSION && \
    echo "Disconets-flow => ${DISCONETSFLOW_VERSION}\n" >> VERSION && \
    echo "Freesurfer-flow => ${FREESURFERFLOW_VERSION}\n" >> VERSION && \
    echo "Disconnect-flow => ${DISCONNECTFLOW_VERSION}\n" >> VERSION && \
    echo "Freewater-flow => ${FREEWATERFLOW_VERSION}\n" >> VERSION && \
    echo "NODDI-flow => ${NODDIFLOW_VERSION}\n" >> VERSION && \
    echo "Convert-SET-flow => ${CONVERTSETFLOW_VERSION}\n" >> VERSION && \
    echo "Registration-flow => ${REGISTRATIONFLOW_VERSION}\n" >> VERSION && \
    echo "BST-flow => ${BSTFLOW_VERSION}\n" >> VERSION
