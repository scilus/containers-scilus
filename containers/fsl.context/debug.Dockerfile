# syntax=docker.io/docker/dockerfile:1.5.0

FROM base-image as debug

WORKDIR /
RUN mkdir -p /fsl_build

WORKDIR /fsl_build
COPY --chmod=755 --link fslinstaller.py .
COPY --chmod=666 --link fsl_conda_env.yml .

RUN ls -lha
