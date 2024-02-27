FROM action-runner-base as action-runner

ARG INSTALL_USER
ARG RUN_USER

ENV INSTALL_USER=${INSTALL_USER:-USER}
ENV RUN_USER=${RUN_USER:-USER}

USER $INSTALL_USER

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl

USER $RUN_USER
