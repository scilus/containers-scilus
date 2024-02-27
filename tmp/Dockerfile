FROM scilus/action-runner:2.312.0-vtk9.2.6 as builder

USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl

USER runner
